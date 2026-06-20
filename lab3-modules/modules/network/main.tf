resource "aws_vpc" "net" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.env_name}-vpc"
  }
}

resource "aws_subnet" "sub" {
  vpc_id     = aws_vpc.net.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = "${var.env_name}-subnet"
  }
}
