terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    ec2 = "http://localhost:4566"
  }
}

module "network" {
  source = "../../modules/network"

  env_name    = "prod"
  vpc_cidr    = "172.16.0.0/16"
  subnet_cidr = "172.16.1.0/24"
}
