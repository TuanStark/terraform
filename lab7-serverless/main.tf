# 1. Tạo bảng cơ sở dữ liệu NoSQL DynamoDB
resource "aws_dynamodb_table" "users_db" {
  name         = "Users"
  billing_mode = "PAY_PER_REQUEST" # Chuẩn tối ưu hóa chi phí Serverless (Dùng bao nhiêu trả bấy nhiêu)
  hash_key     = "UserId"

  attribute {
    name = "UserId"
    type = "S" # Kiểu dữ liệu String
  }
}

# 2. Đóng gói code Node.js thành file .zip để nạp vào Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "index.js"
  output_path = "lambda_function.zip"
}

# 3. Tạo IAM Role cấp quyền thực thi cho Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 4. Khởi tạo Function Lambda
resource "aws_lambda_function" "api_worker" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "StarkServerlessWorker"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.js.handler" # Chỉ định file index.js và hàm exports.handler
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "nodejs18.x"

  environment {
    variables = {
      DATABASE_NAME = aws_dynamodb_table.users_db.name
    }
  }
}

# 5. Xây dựng cổng API Gateway REST API làm đầu vào kết nối với Lambda
resource "aws_api_gateway_rest_api" "serverless_api" {
  name        = "ServerlessEndpoint"
  description = "Cửa ngõ tiếp nhận API"
}

resource "aws_api_gateway_resource" "user_route" {
  rest_api_id = aws_api_gateway_rest_api.serverless_api.id
  parent_id   = aws_api_gateway_rest_api.serverless_api.root_resource_id
  path_part   = "submit" # Đường dẫn: /submit
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.serverless_api.id
  resource_id   = aws_api_gateway_resource.user_route.id
  http_method   = "POST"
  authorization = "NONE"
}

# Liên kết API Method vừa tạo trực tiếp vào Lambda Function qua Proxy
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.serverless_api.id
  resource_id             = aws_api_gateway_resource.user_route.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY" # Ép API Gateway pass toàn bộ request object vào Lambda
  uri                     = aws_lambda_function.api_worker.invoke_arn
}

# Tiến hành deploy cổng API Gateway lên một môi trường (stage) cụ thể
resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.serverless_api.id
}
