variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "db_subnet_ids" {
  description = "Private subnet IDs for the database tier."
  type        = list(string)
}

variable "db_sg_id" {
  description = "Security group ID for the database tier."
  type        = string
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "master_username" {
  description = "Master username for the database."
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16.3"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "allocated_storage" {
  description = "Allocated database storage in GiB."
  type        = number
}

variable "storage_encrypted" {
  description = "Enable storage encryption."
  type        = bool
  default     = true
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
