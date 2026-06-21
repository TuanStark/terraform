output "alb_dns_name" {
  description = "ALB DNS name."
  value       = module.alb.alb_dns_name
}

output "database_endpoint" {
  description = "Database endpoint."
  value       = module.rds_postgres.db_endpoint
}

output "database_secret_arn" {
  description = "Secrets Manager ARN for the database master password."
  value       = module.rds_postgres.master_user_secret_arn
}
