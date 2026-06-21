variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "owner" {
  description = "Resource owner tag."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones."
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "Application subnet CIDRs."
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "Database subnet CIDRs."
  type        = list(string)
}

variable "enable_nat_gateway_per_az" {
  description = "Create one NAT Gateway per AZ."
  type        = bool
}

variable "app_port" {
  description = "Application port."
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type for the app tier."
  type        = string
}

variable "desired_capacity" {
  description = "Desired app capacity."
  type        = number
}

variable "min_size" {
  description = "Minimum app capacity."
  type        = number
}

variable "max_size" {
  description = "Maximum app capacity."
  type        = number
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "db_master_username" {
  description = "Database master username."
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS."
  type        = number
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS."
  type        = bool
}

variable "db_backup_retention_period" {
  description = "Database backup retention period."
  type        = number
}

variable "db_deletion_protection" {
  description = "Enable deletion protection on the database."
  type        = bool
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot on destroy."
  type        = bool
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS. Leave null for HTTP-only dev environments."
  type        = string
  default     = null
}

variable "enable_alb_deletion_protection" {
  description = "Enable deletion protection on the ALB."
  type        = bool
}

variable "extra_tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}
