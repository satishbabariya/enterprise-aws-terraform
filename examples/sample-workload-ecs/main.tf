################################################################################
# Sample workload: a containerized HTTP app on ECS Fargate behind an internet-
# facing ALB, with an Aurora PostgreSQL database, secrets in Secrets Manager,
# WAF in front of the ALB, and Backup-tagged so it's picked up by the central
# backup plan.
#
# Demonstrates how to compose the modules from this template into a real
# end-to-end application deployment. Copy this directory, adapt the variables,
# and you have a production-ready workload baseline in ~200 lines of HCL.
################################################################################

locals {
  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

# ----- Baseline: KMS, secrets, state backend, GitHub OIDC role -----
module "workload_baseline" {
  source                  = "../../modules/workload-baseline"
  org_name                = var.org_name
  account_name            = var.account_name
  account_id              = var.account_id
  region                  = var.region
  log_archive_bucket_arn  = var.log_archive_bucket_arn
  log_archive_bucket_name = var.log_archive_bucket_name
  github_org              = var.github_org
  github_repo             = var.github_repo
}

# ----- Network: VPC with 3-tier subnets + flow logs + endpoints + EKS tags -----
module "vpc" {
  source                = "../../modules/vpc"
  org_name              = var.org_name
  account_name          = var.account_name
  region                = var.region
  cidr_block            = var.vpc_cidr
  availability_zones    = local.azs
  public_subnet_cidrs   = [cidrsubnet(var.vpc_cidr, 8, 0), cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
  private_subnet_cidrs  = [cidrsubnet(var.vpc_cidr, 8, 10), cidrsubnet(var.vpc_cidr, 8, 11), cidrsubnet(var.vpc_cidr, 8, 12)]
  isolated_subnet_cidrs = [cidrsubnet(var.vpc_cidr, 8, 20), cidrsubnet(var.vpc_cidr, 8, 21), cidrsubnet(var.vpc_cidr, 8, 22)]

  log_archive_bucket_arn = var.log_archive_bucket_arn
  flow_log_kms_key_arn   = module.workload_baseline.kms_key_arn
}

# ----- App security group: allows ingress only from the ALB -----
resource "aws_security_group" "app" {
  name        = "${var.app_name}-tasks"
  description = "ECS tasks for ${var.app_name}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "App port from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All egress (NAT GW for outbound; tightened by NACL/Network Firewall in real deployment)"
  }
}

# ----- ALB security group: ingress 443 from internet, egress to app -----
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-alb"
  description = "ALB for ${var.app_name}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Forward to backends"
  }
}

# ----- ECS cluster (Fargate, enhanced Container Insights, ECS Exec) -----
module "ecs" {
  source      = "../../modules/ecs-cluster"
  name        = "${var.app_name}-cluster"
  kms_key_arn = module.workload_baseline.kms_key_arn
}

# ----- Aurora PostgreSQL: managed master password + IAM auth + Backup tagged -----
module "database" {
  source                     = "../../modules/aurora-baseline"
  name                       = "${var.app_name}-db"
  engine                     = "aurora-postgresql"
  engine_version             = "16.4"
  vpc_id                     = module.vpc.vpc_id
  isolated_subnet_ids        = module.vpc.isolated_subnet_ids
  allowed_security_group_ids = [aws_security_group.app.id]
  kms_key_arn                = module.workload_baseline.kms_key_arn
  db_name                    = replace(var.app_name, "-", "_")
  instance_count             = 2
  instance_class             = "db.r6g.large"
}

# ----- WAFv2 in front of the ALB -----
module "waf" {
  source              = "../../modules/waf-baseline"
  org_name            = var.org_name
  name_suffix         = var.app_name
  scope               = "REGIONAL"
  rate_limit_per_5min = 5000
  log_destination_arn = "" # supply Firehose/CW Logs ARN if SIEM integration needed
}

# ----- ALB + listener + target group -----
resource "aws_lb" "this" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnet_ids

  drop_invalid_header_fields = true
  enable_deletion_protection = true

  access_logs {
    bucket  = var.log_archive_bucket_name
    prefix  = "alb-logs/${var.app_name}"
    enabled = true
  }
}

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.this.arn
  web_acl_arn  = module.waf.web_acl_arn
}

resource "aws_lb_target_group" "this" {
  name        = "${var.app_name}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    enabled             = true
    path                = "/healthz"
    matcher             = "200-299"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  deregistration_delay = 30
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# Redirect HTTP -> HTTPS so callers that hit :80 by mistake get bounced.
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# ----- CloudWatch log group for the app container -----
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 90
  kms_key_id        = module.workload_baseline.kms_key_arn
}

# ----- Task IAM role: app permissions go here -----
resource "aws_iam_role" "task" {
  name = "${var.app_name}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Allow the task to use IAM DB auth against the Aurora cluster.
resource "aws_iam_role_policy" "task_db" {
  name = "aurora-iam-auth"
  role = aws_iam_role.task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["rds-db:connect"]
      Resource = [
        "arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:${module.database.cluster_arn}/dbadmin",
      ]
    }]
  })
}

# ----- Task definition -----
resource "aws_ecs_task_definition" "this" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_cpu
  memory                   = var.app_memory
  execution_role_arn       = module.ecs.task_execution_role_arn
  task_role_arn            = aws_iam_role.task.arn

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([{
    name      = var.app_name
    image     = var.app_image
    essential = true
    portMappings = [{
      containerPort = var.app_port
      protocol      = "tcp"
    }]
    environment = [
      { name = "AWS_REGION", value = var.region },
      { name = "DB_HOST", value = module.database.cluster_endpoint },
      { name = "DB_PORT", value = tostring(module.database.port) },
      { name = "DB_NAME", value = replace(var.app_name, "-", "_") },
    ]
    secrets = [
      { name = "DB_CREDENTIALS_ARN", valueFrom = module.database.secret_arn },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.app.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
    readonlyRootFilesystem = true
    linuxParameters = {
      initProcessEnabled = true
    }
    healthCheck = {
      command  = ["CMD-SHELL", "wget -qO- http://localhost:${var.app_port}/healthz || exit 1"]
      interval = 30
      timeout  = 5
      retries  = 3
    }
  }])

  tags = {
    # Picked up by the central AWS Backup plan via the Backup=true tag selector.
    Backup = "true"
  }
}

# ----- ECS service -----
resource "aws_ecs_service" "this" {
  name            = var.app_name
  cluster         = module.ecs.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.app_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnet_ids
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.app_name
    container_port   = var.app_port
  }

  enable_execute_command = true # ECS Exec for ops shell access (KMS-encrypted via cluster config)

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [aws_lb_listener.https]
}
