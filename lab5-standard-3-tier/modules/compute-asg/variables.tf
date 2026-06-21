variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "app_subnet_ids" {
  description = "Private subnet IDs for the app tier."
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security group ID for the app tier."
  type        = string
}

variable "target_group_arns" {
  description = "ALB target group ARNs."
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for application instances."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "app_port" {
  description = "Application port."
  type        = number
  default     = 80
}

variable "desired_capacity" {
  description = "Desired ASG capacity."
  type        = number
}

variable "min_size" {
  description = "Minimum ASG capacity."
  type        = number
}

variable "max_size" {
  description = "Maximum ASG capacity."
  type        = number
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring on the instance."
  type        = bool
  default     = true
}

variable "associate_public_ip_address" {
  description = "Associate public IP to instances."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
