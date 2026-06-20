output "vpc_id" {
  value = aws_vpc.net.id
}

output "subnet_id" {
  value = aws_subnet.sub.id
}
