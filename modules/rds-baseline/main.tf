locals {
  port = var.engine == "postgres" ? 5432 : 3306

  parameter_group_family = (
    var.engine == "postgres" ?
    "postgres${split(".", var.engine_version)[0]}" :
    "mysql${join(".", slice(split(".", var.engine_version), 0, 1))}"
  )
}

resource "aws_db_subnet_group" "this" {
  name        = "${var.name}-subnet-group"
  description = "Isolated subnets for ${var.name}"
  subnet_ids  = var.isolated_subnet_ids
  tags        = var.tags
}

resource "aws_security_group" "this" {
  name        = "${var.name}-rds-sg"
  description = "Allow DB port from approved security groups only"
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
    description = "All egress (for outbound API calls)"
  }

  tags = merge(var.tags, { Name = "${var.name}-rds-sg" })
}

# Parameter group enforcing TLS and audit logging
resource "aws_db_parameter_group" "this" {
  name        = "${var.name}-params"
  family      = local.parameter_group_family
  description = "Compliance-enforced parameters for ${var.name}"

  dynamic "parameter" {
    for_each = var.engine == "postgres" ? [
      { name = "rds.force_ssl", value = "1" },
      { name = "log_statement", value = "all" },
      { name = "log_min_duration_statement", value = "500" },
      { name = "log_connections", value = "1" },
      { name = "log_disconnections", value = "1" },
    ] : []
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  dynamic "parameter" {
    for_each = var.engine == "mysql" ? [
      { name = "require_secure_transport", value = "ON" },
      { name = "general_log", value = "1" },
      { name = "log_output", value = "FILE" },
    ] : []
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier = var.name

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage_gb
  max_allocated_storage = var.max_allocated_storage_gb
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_name  = var.db_name
  username = var.master_username
  # Password is managed by Secrets Manager rotation
  manage_master_user_password = true
  master_user_secret_kms_key_id = var.kms_key_arn

  port                   = local.port
  vpc_security_group_ids = [aws_security_group.this.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  publicly_accessible    = false

  multi_az                     = var.multi_az
  backup_retention_period      = var.backup_retention_days
  backup_window                = var.backup_window
  maintenance_window           = var.maintenance_window
  copy_tags_to_snapshot        = true
  deletion_protection          = var.deletion_protection
  delete_automated_backups     = false
  skip_final_snapshot          = false
  final_snapshot_identifier    = "${var.name}-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.kms_key_arn
  performance_insights_retention_period = 7

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.monitoring.arn

  enabled_cloudwatch_logs_exports = var.engine == "postgres" ? ["postgresql", "upgrade"] : ["audit", "error", "general", "slowquery"]

  iam_database_authentication_enabled = true
  auto_minor_version_upgrade          = true

  tags = merge(var.tags, { Backup = "true" })

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }
}

resource "aws_iam_role" "monitoring" {
  name = "${var.name}-rds-enhanced-monitoring"

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
