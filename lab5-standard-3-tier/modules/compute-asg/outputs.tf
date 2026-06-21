output "autoscaling_group_name" {
  description = "Auto Scaling Group name."
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "Launch Template ID."
  value       = aws_launch_template.this.id
}

output "instance_profile_name" {
  description = "Instance profile name."
  value       = aws_iam_instance_profile.this.name
}
