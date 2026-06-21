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

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID for the ALB."
  type        = string
}

variable "target_group_port" {
  description = "Target group port."
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Target group protocol."
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Health check path."
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener. Leave null to keep HTTP only."
  type        = string
  default     = null
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
