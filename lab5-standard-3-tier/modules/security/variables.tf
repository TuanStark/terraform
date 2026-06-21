variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "app_port" {
  description = "Application port."
  type        = number
  default     = 80
}

variable "db_port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "alb_ingress_cidrs" {
  description = "CIDR ranges allowed to reach the ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "common_tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
