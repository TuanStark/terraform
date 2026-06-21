provider "aws" {
  region     = "us-east-1"
  access_key = "mock"
  secret_key = "mock"
}

terraform {
  backend "s3" {
    # Chỉ cần khai báo như này thôi thì terraform sẽ tự động đẩy terraform.tfstate
    bucket = "my-shared-state-bucket"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"

    # Chuẩn mới thay cho dynamodb_table
    use_lockfile = true

    # Chuẩn mới thay cho force_path_style
    use_path_style = true

    # Cấu hình endpoint kiểu mới gom vào block endpoints
    endpoints = {
      s3       = "http://localhost:4566"
      dynamodb = "http://localhost:4566"
      iam      = "http://localhost:4566"
      sts      = "http://localhost:4566"
    }

    lifecycle {
      prevent_destroy = true # Ép Terraform báo lỗi nếu ai đó cố tình gõ lệnh destroy
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}
# Tài nguyên demo để test lock
resource "aws_s3_bucket" "test_lock" {
  bucket = "lab4-demo-lock-bucket"
}
