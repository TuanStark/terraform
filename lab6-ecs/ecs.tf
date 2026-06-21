# 1. Tạo kho chứa Docker Image (Elastic Container Registry)
resource "aws_ecr_repository" "app_repo" {
  name                 = "stark-microservice-repo"
  image_tag_mutability = "MUTABLE"
}

# 2. Tạo cụm điều phối Container (ECS Cluster)
resource "aws_ecs_cluster" "main_cluster" {
  name = "production-ecs-cluster"
}

# 3. Tạo IAM Role cho phép ECS Task thực thi các tác vụ (như pull image, ghi log)
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

# 4. Định nghĩa cấu hình phần cứng cho Container (Task Definition)
resource "aws_ecs_task_definition" "app_task" {
  family                   = "stark-app-task"
  network_mode             = "awsvpc" # Bắt buộc đối với Fargate nhằm cấp IP riêng cho từng container
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # Tương đương 0.25 vCPU
  memory                   = "512" # 512 MB RAM
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  # Định nghĩa các container sẽ chạy bên trong Task (giống như file docker-compose)
  container_definitions = jsonencode([
    {
      name      = "web-api"
      image     = "nginx:latest" # Trong thực tế sẽ truyền URL từ repo ECR: ${aws_ecr_repository.app_repo.repository_url}:latest
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# 5. Khởi chạy và quản lý số lượng Container mong muốn (ECS Service)
resource "aws_ecs_service" "app_service" {
  name            = "stark-web-service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 2 # Duy trì chạy liên tục đúng 2 container phục vụ chịu tải
  launch_type     = "FARGATE"

  # Cấu hình mạng độc lập cho Container
  network_configuration {
    subnets          = ["subnet-123456"] # Giả lập gán bừa ID subnet hoặc lấy từ Lab 1
    assign_public_ip = true
  }
}
