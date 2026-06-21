data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

module "network" {
  source = "../../modules/network"

  project                   = var.project
  environment               = var.environment
  vpc_cidr                  = var.vpc_cidr
  availability_zones        = var.availability_zones
  public_subnet_cidrs       = var.public_subnet_cidrs
  app_subnet_cidrs          = var.app_subnet_cidrs
  db_subnet_cidrs           = var.db_subnet_cidrs
  enable_nat_gateway_per_az = var.enable_nat_gateway_per_az
  common_tags               = local.common_tags
}

module "security" {
  source = "../../modules/security"

  project     = var.project
  environment = var.environment
  vpc_id      = module.network.vpc_id
  app_port    = var.app_port
  common_tags = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  project                    = var.project
  environment                = var.environment
  vpc_id                     = module.network.vpc_id
  public_subnet_ids          = module.network.public_subnet_ids
  alb_sg_id                  = module.security.alb_sg_id
  target_group_port          = var.app_port
  health_check_path          = "/"
  certificate_arn            = var.acm_certificate_arn
  enable_deletion_protection = var.enable_alb_deletion_protection
  common_tags                = local.common_tags
}

module "compute_asg" {
  source = "../../modules/compute-asg"

  project           = var.project
  environment       = var.environment
  app_subnet_ids    = module.network.app_subnet_ids
  app_sg_id         = module.security.app_sg_id
  target_group_arns = [module.alb.target_group_arn]
  ami_id            = data.aws_ami.amazon_linux.id
  instance_type     = var.instance_type
  app_port          = var.app_port
  desired_capacity  = var.desired_capacity
  min_size          = var.min_size
  max_size          = var.max_size
  common_tags       = local.common_tags
}

module "rds_postgres" {
  source = "../../modules/rds-postgres"

  project                 = var.project
  environment             = var.environment
  db_subnet_ids           = module.network.db_subnet_ids
  db_sg_id                = module.security.db_sg_id
  db_name                 = var.db_name
  master_username         = var.db_master_username
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot
  common_tags             = local.common_tags
}
