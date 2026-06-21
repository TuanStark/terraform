locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}

resource "aws_db_instance" "this" {
  identifier                      = "${local.name_prefix}-postgres"
  engine                          = "postgres"
  engine_version                  = var.engine_version
  instance_class                  = var.instance_class
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.allocated_storage * 2
  db_name                         = var.db_name
  username                        = var.master_username
  manage_master_user_password     = true
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [var.db_sg_id]
  storage_encrypted               = var.storage_encrypted
  multi_az                        = var.multi_az
  backup_retention_period         = var.backup_retention_period
  deletion_protection             = var.deletion_protection
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${local.name_prefix}-final-snapshot"
  apply_immediately               = var.apply_immediately
  publicly_accessible             = false
  auto_minor_version_upgrade      = true
  performance_insights_enabled    = var.performance_insights_enabled
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-postgres"
  })
}
