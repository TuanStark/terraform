variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for the deployment."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for application subnets."
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for database subnets."
  type        = list(string)
}

variable "enable_nat_gateway_per_az" {
  description = "Create one NAT Gateway per AZ instead of a single shared gateway."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
