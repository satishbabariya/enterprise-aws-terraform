locals {
  port = var.engine == "aurora-postgresql" ? 5432 : 3306

  cluster_parameter_group_family = (
    var.engine == "aurora-postgresql" ?
    "aurora-postgresql${split(".", var.engine_version)[0]}" :
    "aurora-mysql${join(".", slice(split(".", var.engine_version), 0, 1))}"
  )
}

resource "aws_db_subnet_group" "this" {
  name        = "${var.name}-subnet-group"
  description = "Isolated subnets for ${var.name}"
  subnet_ids  = var.isolated_subnet_ids
  tags        = var.tags
}

# Aurora needs outbound to AWS service endpoints (Secrets Manager rotation +
# IAM DB auth STS). No VPC endpoint exists for every required API.
#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "this" {
  name        = "${var.name}-aurora-sg"
  description = "Allow DB port from approved security groups"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      from_port       = local.port
      to_port         = local.port
      protocol        = "tcp"
      security_groups = [ingress.value]
      description     = "Allow from ${ingress.value}"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All egress (Secrets Manager rotation + IAM auth STS)"
  }

  tags = merge(var.tags, { Name = "${var.name}-aurora-sg" })
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = "${var.name}-cluster-params"
  family      = local.cluster_parameter_group_family
  description = "Compliance-enforced cluster parameters"

  dynamic "parameter" {
    for_each = var.engine == "aurora-postgresql" ? [
      { name = "rds.force_ssl", value = "1" },
    ] : []
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  dynamic "parameter" {
    for_each = var.engine == "aurora-mysql" ? [
      { name = "require_secure_transport", value = "ON" },
    ] : []
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = var.tags
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = var.name

  engine         = var.engine
  engine_version = var.engine_version

  database_name   = var.db_name
  master_username = var.master_username

  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.kms_key_arn

  port = local.port

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  backup_retention_period = var.backup_retention_days
  preferred_backup_window = "03:00-05:00"

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.name}-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  copy_tags_to_snapshot     = true

  iam_database_authentication_enabled = true

  enabled_cloudwatch_logs_exports = var.engine == "aurora-postgresql" ? ["postgresql"] : ["audit", "error", "general", "slowquery"]

  tags = merge(var.tags, { Backup = "true" })

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }
}

resource "aws_rds_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${var.name}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this.id
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  instance_class     = var.instance_class

  db_subnet_group_name = aws_db_subnet_group.this.name

  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.kms_key_arn
  performance_insights_retention_period = 7

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.monitoring.arn

  auto_minor_version_upgrade = true

  tags = var.tags
}

resource "aws_iam_role" "monitoring" {
  name = "${var.name}-aurora-enhanced-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  role       = aws_iam_role.monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ============================================================
# RDS Proxy (optional)
# Sits between clients and the cluster. Pools connections,
# supports IAM auth, and shortens failover RTO.
# ============================================================
resource "aws_iam_role" "proxy" {
  count = var.enable_rds_proxy ? 1 : 0

  name = "${var.name}-rds-proxy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "proxy" {
  count = var.enable_rds_proxy ? 1 : 0

  name = "secrets-and-kms"
  role = aws_iam_role.proxy[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = aws_rds_cluster.this.master_user_secret[0].secret_arn
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = var.kms_key_arn
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })
}

data "aws_region" "current" {}

resource "aws_db_proxy" "this" {
  count = var.enable_rds_proxy ? 1 : 0

  name                   = "${var.name}-proxy"
  engine_family          = var.engine == "aurora-postgresql" ? "POSTGRESQL" : "MYSQL"
  role_arn               = aws_iam_role.proxy[0].arn
  vpc_subnet_ids         = var.isolated_subnet_ids
  vpc_security_group_ids = [aws_security_group.this.id]
  require_tls            = var.rds_proxy_require_tls
  idle_client_timeout    = var.rds_proxy_idle_client_timeout_seconds

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "REQUIRED"
    secret_arn  = aws_rds_cluster.this.master_user_secret[0].secret_arn
  }

  tags = var.tags
}

resource "aws_db_proxy_default_target_group" "this" {
  count = var.enable_rds_proxy ? 1 : 0

  db_proxy_name = aws_db_proxy.this[0].name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    session_pinning_filters      = []
  }
}

resource "aws_db_proxy_target" "this" {
  count = var.enable_rds_proxy ? 1 : 0

  db_cluster_identifier = aws_rds_cluster.this.id
  db_proxy_name         = aws_db_proxy.this[0].name
  target_group_name     = aws_db_proxy_default_target_group.this[0].name
}
