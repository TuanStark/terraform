# Hướng dẫn sử dụng Terraform & LocalStack Lab

Dự án này là môi trường thực hành Terraform từ cơ bản đến nâng cao, sử dụng **LocalStack** để giả lập các dịch vụ đám mây AWS ngay trên máy local của bạn mà không tốn chi phí thực tế.

---

## 📂 Cấu trúc dự án

*   **`docker-compose.yml`**: Định nghĩa container LocalStack chạy các dịch vụ AWS giả lập (EC2, S3, VPC, IAM, STS, DynamoDB, RDS, SQS, SNS).
*   **`.env` / `.env.examples`**: Tệp lưu cấu hình token LocalStack (`LOCALSTACK_AUTH_TOKEN`).
*   **`terraform-lab01/`**: Lab cơ bản sử dụng `local` provider để thao tác với file trên máy local.
*   **`terraform-lab02/`**: Lab sử dụng `docker` provider để tạo container Docker (Nginx) bằng Terraform.
*   **`lab1-basic-ec2/`**: Lab AWS đầu tiên triển khai cấu trúc mạng (VPC, Subnet, SG) và một máy ảo EC2 trên LocalStack.

---

## 🛠️ Yêu cầu hệ thống & Hướng dẫn cài đặt

Để chạy dự án một cách trơn tru nhất, bạn cần cài đặt các công cụ sau:

### 1. Docker & Docker Compose
Đảm bảo Docker đã được cài đặt và đang chạy trên hệ thống của bạn.

### 2. Cài đặt Terraform CLI
Nếu máy của bạn chưa có `terraform`, cài đặt thông qua HashiCorp repo:
```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform
```

### 3. Cài đặt `tflocal` và `awslocal`
`tflocal` và `awslocal` là hai công cụ dòng lệnh (CLI wrappers) vô cùng tiện lợi giúp tự động cấu hình các endpoint dịch vụ AWS hướng về LocalStack (`http://localhost:4566`) thay vì AWS Cloud thực tế.

Cài đặt bằng `pipx` hoặc `pip`:
```bash
# Cài đặt qua pipx (khuyên dùng)
pipx install terraform-local
pipx install awscli-local

# Hoặc cài đặt qua pip thông thường
pip install terraform-local awscli-local
```

> [!IMPORTANT]
> **Cấu hình biến môi trường PATH:**  
> Hãy chắc chắn rằng thư mục lưu trữ binaries của Python user (thường là `$HOME/.local/bin`) đã nằm trong biến môi trường `$PATH` của bạn.  
> Để thêm vĩnh viễn, chạy lệnh sau:
> ```bash
> echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
> # Hoặc ~/.zshrc nếu bạn dùng zsh
> source ~/.bashrc
> ```

---

## 🚀 Hướng dẫn chạy dự án từng bước

### Bước 1: Khởi động LocalStack
1. Tạo file cấu hình môi trường `.env` từ file ví dụ:
   ```bash
   cp .env.examples .env
   ```
2. Điền `LOCALSTACK_AUTH_TOKEN` của bạn vào file `.env` nếu có (để kích hoạt đầy đủ tính năng nâng cao).
3. Khởi chạy LocalStack container:
   ```bash
   # Sử dụng lệnh docker compose chuẩn
   docker compose up -d
   
   # Hoặc dùng các alias sẵn có trên hệ thống của bạn (ví dụ: dcupd)
   ```
4. Kiểm tra xem LocalStack đã chạy thành công chưa:
   ```bash
   docker ps | grep localstack
   ```

---

### Bước 2: Thực hành Lab 01 (Local Provider)
Lab này giúp bạn làm quen với cú pháp Terraform cơ bản mà không cần AWS.
1. Di chuyển vào thư mục lab:
   ```bash
   cd terraform-lab01
   ```
2. Khởi tạo Terraform:
   ```bash
   terraform init
   ```
3. Xem trước các tài nguyên sẽ tạo:
   ```bash
   terraform plan
   ```
4. Áp dụng cấu hình để tạo file `hello.txt`:
   ```bash
   terraform apply -auto-approve
   ```
5. Sau khi kiểm tra xong, bạn có thể dọn dẹp tài nguyên:
   ```bash
   terraform destroy -auto-approve
   ```

---

### Bước 3: Thực hành Lab 02 (Docker Provider)
Lab này sử dụng Docker provider để quản lý các container Docker thông qua Terraform.
1. Di chuyển vào thư mục lab:
   ```bash
   cd ../terraform-lab02
   ```
2. Khởi tạo và chạy Terraform:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```
3. Kiểm tra xem container Nginx đã chạy tại cổng `8080` chưa:
   ```bash
   docker ps | grep nginx
   # hoặc truy cập http://localhost:8080
   ```
4. Dọn dẹp tài nguyên:
   ```bash
   terraform destroy -auto-approve
   ```

---

### Bước 4: Thực hành Lab 1 (Basic EC2 trên LocalStack)
Đây là lab quan trọng nhất, hướng dẫn bạn cách triển khai hạ tầng AWS giả lập.

1. Di chuyển vào thư mục lab:
   ```bash
   cd ../lab1-basic-ec2
   ```
2. **Sử dụng `tflocal`** thay vì `terraform` thông thường để tự động trỏ các endpoint về LocalStack:
   ```bash
   tflocal init
   ```
3. Xem trước cấu hình hạ tầng (VPC, Subnet, Security Group, EC2 Instance):
   ```bash
   tflocal plan
   ```
4. Triển khai hạ tầng lên LocalStack:
   ```bash
   tflocal apply -auto-approve
   ```

#### 🔍 Kiểm tra kết quả trên LocalStack
Sử dụng `awslocal` để kiểm tra tài nguyên vừa tạo mà không cần mở AWS Console thật:

*   **Kiểm tra EC2 Instance vừa tạo:**
    ```bash
    awslocal ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]" --output table
    ```
*   **Kiểm tra VPC:**
    ```bash
    awslocal ec2 describe-vpcs
    ```

5. Sau khi hoàn tất, tiến hành hủy hạ tầng đã dựng để tránh chiếm tài nguyên máy ảo:
   ```bash
   tflocal destroy -auto-approve
   ```

---

## 💡 Lưu ý quan trọng & Best Practices

1. **Sử dụng `tflocal` thay thế cho `terraform`**:
   * Khi làm việc với LocalStack, nếu dùng lệnh `terraform` thuần túy, Terraform sẽ cố gắng kết nối trực tiếp đến hệ thống AWS Cloud thật (điều này sẽ lỗi vì credentials trong `main.tf` chỉ là `mock` keys).
   * `tflocal` là giải pháp sạch và tốt nhất vì nó giữ cho code Terraform của bạn hoàn toàn nguyên bản (không cần khai báo thủ công block `endpoints` phức tạp cho từng dịch vụ trong provider block).

2. **Cách cấu hình credentials trong Code Terraform**:
   * Khi triển khai trên LocalStack, provider AWS chỉ cần thông tin giả lập như sau:
     ```hcl
     provider "aws" {
       region     = "us-east-1"
       access_key = "mock"
       secret_key = "mock"
     }
     ```

3. **Dọn dẹp môi trường khi kết thúc**:
   * Sau khi hoàn tất tất cả bài thực hành, hãy tắt LocalStack container để giải phóng bộ nhớ RAM và CPU:
     ```bash
     docker compose down
     ```
