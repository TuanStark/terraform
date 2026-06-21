output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = [for subnet in values(aws_subnet.public) : subnet.id]
}

output "app_subnet_ids" {
  description = "Application subnet IDs."
  value       = [for subnet in values(aws_subnet.app) : subnet.id]
}

output "db_subnet_ids" {
  description = "Database subnet IDs."
  value       = [for subnet in values(aws_subnet.db) : subnet.id]
}

output "availability_zones" {
  description = "Availability zones used by the stack."
  value       = var.availability_zones
}
