provider "aws" {
  region     = "us-east-1"
  access_key = "mock"
  secret_key = "mock"
}

# Dùng vòng lặp tạo nhiều bucket dựa trên list biến số
resource "aws_s3_bucket" "my_buckets" {
  for_each = toset(var.bucket_suffix)

  # Tạo tên dạng: dev-media-bucket, dev-logs-bucket...
  bucket = "${var.environment}-${each.value}-bucket"
}

# Cấu hình Lifecycle rule cho từng bucket bằng vòng lặp
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  for_each = aws_s3_bucket.my_buckets

  bucket = each.value.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    expiration {
      days = 30 # Tự động xóa file sau 30 ngày
    }
  }
}
