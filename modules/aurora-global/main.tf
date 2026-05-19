resource "aws_rds_global_cluster" "this" {
  provider = aws.primary

  global_cluster_identifier = var.global_name
  engine                    = var.engine
  engine_version            = var.engine_version
  database_name             = var.database_name
  storage_encrypted         = true
  deletion_protection       = var.deletion_protection
}

# Primary region cluster
resource "aws_rds_cluster" "primary" {
  provider = aws.primary

  cluster_identifier        = var.primary_cluster_identifier
  global_cluster_identifier = aws_rds_global_cluster.this.id
  engine                    = aws_rds_global_cluster.this.engine
  engine_version            = aws_rds_global_cluster.this.engine_version

  database_name = var.database_name
  master_username = var.master_username
  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.primary_kms_key_arn

  db_subnet_group_name   = var.primary_db_subnet_group_name
  vpc_security_group_ids = var.primary_vpc_security_group_ids

  storage_encrypted = true
  kms_key_id        = var.primary_kms_key_arn

  backup_retention_period   = var.backup_retention_days
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.primary_cluster_identifier}-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  copy_tags_to_snapshot     = true

  iam_database_authentication_enabled = true

  tags = merge(var.tags, { Backup = "true" })

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }
}

resource "aws_rds_cluster_instance" "primary" {
  provider = aws.primary
  count    = var.instance_count_per_region

  identifier         = "${var.primary_cluster_identifier}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.primary.id
  engine             = aws_rds_cluster.primary.engine
  engine_version     = aws_rds_cluster.primary.engine_version
  instance_class     = var.instance_class

  db_subnet_group_name = var.primary_db_subnet_group_name

  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.primary_kms_key_arn

  auto_minor_version_upgrade = true

  tags = var.tags
}

# Secondary region cluster - read-only replica
resource "aws_rds_cluster" "secondary" {
  provider = aws.secondary

  cluster_identifier        = var.secondary_cluster_identifier
  global_cluster_identifier = aws_rds_global_cluster.this.id
  engine                    = aws_rds_global_cluster.this.engine
  engine_version            = aws_rds_global_cluster.this.engine_version

  db_subnet_group_name   = var.secondary_db_subnet_group_name
  vpc_security_group_ids = var.secondary_vpc_security_group_ids

  storage_encrypted = true
  kms_key_id        = var.secondary_kms_key_arn

  backup_retention_period   = var.backup_retention_days
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.secondary_cluster_identifier}-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  copy_tags_to_snapshot     = true

  tags = merge(var.tags, { Backup = "true" })

  depends_on = [aws_rds_cluster_instance.primary]

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      replication_source_identifier,
    ]
  }
}

resource "aws_rds_cluster_instance" "secondary" {
  provider = aws.secondary
  count    = var.instance_count_per_region

  identifier         = "${var.secondary_cluster_identifier}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.secondary.id
  engine             = aws_rds_cluster.secondary.engine
  engine_version     = aws_rds_cluster.secondary.engine_version
  instance_class     = var.instance_class

  db_subnet_group_name = var.secondary_db_subnet_group_name

  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.secondary_kms_key_arn

  auto_minor_version_upgrade = true

  tags = var.tags
}
