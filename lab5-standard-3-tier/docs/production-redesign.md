# Production Redesign Blueprint

## 1. Executive Summary

Repo hien tai mo ta dung y tuong 3-tier tren AWS, nhung chua dat muc do "production-ready" va hien cung chua module hoa dung cach de `terraform plan/apply` on dinh.

Van de lon nhat khong nam o viec thieu resource, ma nam o 3 nhom loi kien truc:

1. Boundary giua cac module dang sai.
2. Root environment chua duoc to chuc nhu mot "deployment unit" thuc te.
3. Thieu cac baseline production ve security, reliability, observability, state va delivery.

## 2. Danh Gia Hien Trang

### 2.1 Diem dung

- Da co tu duy 3-tier: public, app, db.
- Da co VPC, subnet tach theo tier, IGW, NAT, route table.
- Da co security group cho LB, app, database.
- Da co ALB, EC2 va RDS o muc proof-of-concept.
- Da tach `environments/` va `modules/`, day la huong di dung.

### 2.2 Diem sai va rui ro nghiem trong

- `environments/dev/main.tf` goi sai source module `security-groups` trong khi thu muc that la `security-group`.
- `modules/ec2/compute.tf` dang chua ca ALB + target group + listener + EC2, lam vo boundary giua compute va ingress.
- `modules/alb` thuc te khong phai module ALB, chi co mot `provider.tf` voi mock credentials.
- Cac module `ec2`, `rds`, `security-group` dang tham chieu truc tiep resource cua module khac nhu `aws_vpc.main`, `aws_subnet.*`, `aws_security_group.*`; day la sai nguyen tac module trong Terraform.
- ALB dang dat vao `public_1` va `db_2`; dat ALB trong DB subnet la sai mo hinh.
- EC2 moi chi co 1 instance, khong co launch template, autoscaling, health-based replacement.
- RDS hard-code password va chua co Multi-AZ, backup, encryption, deletion protection.
- Tat ca `backend.tf` va `terraform.tfvars` dang rong.
- `staging` va `prod` dang rong, nen khong co kha nang promote nhat quan giua cac moi truong.

### 2.3 Danh gia theo maturity

- Networking: 5/10
- Security baseline: 2/10
- Reliability/HA: 2/10
- Operability/Observability: 1/10
- Terraform design quality: 2/10
- Production readiness tong the: 2/10

## 3. Muc Tieu Kien Truc Production

Muc tieu khong phai chi la "deploy duoc", ma la:

- Co the van hanh on dinh cho dev, staging, prod.
- Co kha nang mo rong va thay the instance an toan.
- Tach ro boundary giua network, security, compute, data, observability.
- Khong hard-code secret.
- Co remote state, locking, pipeline, review gate.
- Co cau truc repo de team infra van hanh lau dai.

## 4. Thiet Ke Kien Truc Dich

### 4.1 Kien truc de xuat

Luong traffic de xuat:

`Internet -> Route53 -> WAF -> ALB (public subnets) -> ASG EC2/ECS (private app subnets) -> RDS PostgreSQL (private db subnets)`

Thanh phan production nen co:

- 1 VPC.
- 2-3 AZ.
- Public subnets chi dung cho ALB, NAT Gateway.
- Private app subnets cho compute tier.
- Private db subnets cho RDS.
- ALB internet-facing, HTTPS only.
- ACM certificate.
- WAF neu dich vu public.
- Compute layer dung Auto Scaling Group + Launch Template.
- Session Manager thay vi SSH bastion trong da so truong hop.
- RDS PostgreSQL Multi-AZ.
- Secrets Manager luu credential DB.
- KMS key cho EBS, RDS, secrets, logs neu can.
- CloudWatch logs + alarms + dashboard.
- Remote state S3 + DynamoDB locking.
- CI/CD pipeline cho `fmt`, `validate`, `tflint`, `tfsec/checkov`, `plan`, `apply`.

### 4.2 Networking production

Khuyen nghi:

- 2 hoac 3 AZ tuy budget.
- Moi AZ co:
  - 1 public subnet
  - 1 app subnet
  - 1 db subnet
- Neu uu tien HA that su: 1 NAT Gateway moi AZ.
- Neu budget thap cho dev/staging: cho phep 1 NAT Gateway, nhung prod nen tach theo AZ.
- Khong dat compute public IP.
- DB subnet khong co default route ra Internet.
- Can bo sung VPC endpoints cho:
  - SSM
  - EC2 Messages
  - SSM Messages
  - CloudWatch Logs
  - Secrets Manager
  - S3 Gateway endpoint

Loi ich:

- Giam phu thuoc NAT cho traffic noi bo AWS.
- Tang security.
- Tiet kiem chi phi outbound.

### 4.3 Security production

Baseline toi thieu:

- Khong hard-code credentials trong code.
- DB password luu o Secrets Manager.
- EBS va RDS bat encryption.
- IAM role cho instance/task theo least privilege.
- Dung SSM Session Manager, tat SSH inbound.
- ALB chi mo `443`, `80` chi redirect sang `443`.
- SG theo huong:
  - ALB nhan 443 tu Internet.
  - App chi nhan tu SG cua ALB.
  - DB chi nhan 5432 tu SG cua app.
- Bat WAF cho public ALB neu co traffic Internet.
- Bat access logs cho ALB, VPC Flow Logs neu can audit.

### 4.4 Compute production

Neu ung dung con don gian, chay EC2 van duoc, nhung phai dung:

- `aws_launch_template`
- `aws_autoscaling_group`
- target tracking scaling policy
- health check dua theo ALB
- rolling update hoac instance refresh
- user data toi gian, bootstrap thong qua artifact hoac config manager

Neu app co xu huong scale nhieu va team da san sang, nen can nhac:

- ECS Fargate cho stateless web tier

Trong bo canh repo nay, phuong an thuc te nhat la:

- Giai doan 1: EC2 ASG production-ready
- Giai doan 2: tach sang ECS neu nhu cau van hanh tang len

### 4.5 Database production

RDS PostgreSQL nen co:

- `multi_az = true` cho prod
- `storage_encrypted = true`
- `deletion_protection = true` cho prod
- `backup_retention_period >= 7` cho prod
- `performance_insights_enabled = true`
- parameter group rieng
- enhanced monitoring neu can
- maintenance window/backups window ro rang
- final snapshot khi destroy moi truong quan trong

Khong nen:

- hard-code username/password
- `skip_final_snapshot = true` cho prod

### 4.6 Observability production

Can co:

- CloudWatch alarm cho CPU, memory, disk, ALB 5xx, target unhealthy, RDS storage, database connections.
- ALB access logs.
- App logs day len CloudWatch Logs.
- Dashboard tong hop health cho tung environment.
- SNS notification cho su co chinh.

Neu team da co he thong ngoai:

- Datadog / Grafana / Prometheus / OpenSearch co the bo sung sau.

### 4.7 Delivery va governance

Pipeline toi thieu:

1. `terraform fmt -check`
2. `terraform init`
3. `terraform validate`
4. `tflint`
5. `tfsec` hoac `checkov`
6. `terraform plan`
7. Manual approval cho `staging/prod`
8. `terraform apply`

Nen bo sung:

- Branch protection
- CODEOWNERS cho thu muc infra
- Pre-commit hooks
- Policy checks neu team lon

## 5. Thiet Ke Terraform Chuan Thuc Te

### 5.1 Nguyen tac

Muc tieu la:

- Root module chi lam nhiem vu orchestration.
- Reusable module chi nhan `variables` va tra `outputs`.
- Tuyet doi khong tham chieu resource cua module khac tu ben trong module.
- Moi environment co state rieng.
- File naming nhat quan va de tim.

### 5.2 Cau truc thu muc de xuat

```text
lab5-standard-3-tier/
  docs/
    production-redesign.md
    architecture-diagram.md
    runbook.md
  modules/
    network/
      main.tf
      variables.tf
      outputs.tf
      versions.tf
    security/
      main.tf
      variables.tf
      outputs.tf
    alb/
      main.tf
      variables.tf
      outputs.tf
    compute-asg/
      main.tf
      variables.tf
      outputs.tf
      user_data.sh.tftpl
    rds-postgres/
      main.tf
      variables.tf
      outputs.tf
    observability/
      main.tf
      variables.tf
      outputs.tf
    iam/
      main.tf
      variables.tf
      outputs.tf
    secrets/
      main.tf
      variables.tf
      outputs.tf
  stacks/
    dev/
      backend.hcl
      providers.tf
      versions.tf
      locals.tf
      variables.tf
      main.tf
      outputs.tf
      terraform.tfvars
    staging/
      backend.hcl
      providers.tf
      versions.tf
      locals.tf
      variables.tf
      main.tf
      outputs.tf
      terraform.tfvars
    prod/
      backend.hcl
      providers.tf
      versions.tf
      locals.tf
      variables.tf
      main.tf
      outputs.tf
      terraform.tfvars
  policies/
    tflint.hcl
    tfsec-excludes.yaml
  scripts/
    init.ps1
    plan.ps1
    apply.ps1
  .github/
    workflows/
      terraform-plan.yml
      terraform-apply.yml
  README.md
```

Giai thich:

- `modules/`: noi chua logic tai su dung.
- `stacks/`: moi environment la mot root module doc lap.
- `docs/`: tai lieu kien truc, runbook, quy uoc.
- `policies/`: rule cho scanning/linting.
- `scripts/`: script ho tro dev team.

Ten `stacks/` thuc te hon `environments/` vi moi thu muc o day chinh la mot root deployment unit. Neu team quen `environments/` van co the giu, nhung `stacks/` thuong ro nghia hon trong repo Terraform.

## 6. Boundary dung cho tung module

### 6.1 `modules/network`

Chi chiu trach nhiem:

- VPC
- subnets
- IGW
- NAT Gateway
- route tables
- NACL neu can
- VPC endpoints neu quyet dinh de o day

Outputs toi thieu:

- `vpc_id`
- `public_subnet_ids`
- `app_subnet_ids`
- `db_subnet_ids`
- `public_subnet_cidrs`
- `app_subnet_cidrs`
- `db_subnet_cidrs`

### 6.2 `modules/security`

Chi tao:

- SG cho ALB
- SG cho app
- SG cho DB

Inputs:

- `vpc_id`
- `app_port`
- `db_port`
- `allowed_ingress_cidrs` neu can

Outputs:

- `alb_sg_id`
- `app_sg_id`
- `db_sg_id`

### 6.3 `modules/alb`

Chi chiu trach nhiem:

- ALB
- target groups
- listeners
- HTTPS redirect
- access logs
- optional WAF association

Inputs:

- `vpc_id`
- `public_subnet_ids`
- `alb_sg_id`
- `certificate_arn`
- `target_group_port`

Outputs:

- `alb_arn`
- `alb_dns_name`
- `target_group_arn`

### 6.4 `modules/compute-asg`

Chi chiu trach nhiem:

- launch template
- IAM instance profile
- ASG
- scaling policies
- instance refresh
- SSM role attachment

Inputs:

- `app_subnet_ids`
- `app_sg_id`
- `target_group_arns`
- `instance_type`
- `ami_id`
- `desired_capacity`
- `min_size`
- `max_size`
- `secret_arns` neu app can

Outputs:

- `asg_name`
- `launch_template_id`

### 6.5 `modules/rds-postgres`

Chi chiu trach nhiem:

- db subnet group
- db parameter group
- db option group neu can
- RDS instance
- secret lookup
- monitoring options

Inputs:

- `db_subnet_ids`
- `db_sg_id`
- `db_name`
- `db_username`
- `db_password_secret_arn`
- `instance_class`
- `multi_az`

Outputs:

- `db_endpoint`
- `db_port`
- `db_identifier`

## 7. Root Stack mau

Trong `stacks/prod/main.tf`, root chi nen lam cac viec sau:

1. Goi `network`
2. Goi `security`
3. Goi `secrets`
4. Goi `alb`
5. Goi `compute-asg`
6. Goi `rds-postgres`
7. Goi `observability`

Root khong nen:

- Chua resource "la"
- Chua logic lap lai
- Chua hard-coded CIDR/size/secret ngoai file bien

## 8. Bien theo moi truong

Nen tach ro:

- `variables.tf`: schema
- `terraform.tfvars`: gia tri theo tung stack
- `locals.tf`: naming convention, common tags, derived values

Vi du khac biet giua moi truong:

- `dev`
  - 1 NAT Gateway
  - nho hon ve instance/RDS
  - backup retention ngan hon
  - co the tat WAF neu chi noi bo
- `staging`
  - giong prod o muc toi da co the
  - dung de test release va DR practice
- `prod`
  - Multi-AZ
  - deletion protection
  - backup retention dai hon
  - alarm day du
  - WAF/HTTPS/monitoring bat buoc

## 9. Backend va state

State production-ready nen la:

- S3 bucket rieng cho Terraform state
- DynamoDB table cho state locking
- encryption bat
- versioning bat
- access policy toi thieu

Khuyen nghi cau truc key:

```text
s3://company-terraform-state/lab5-standard-3-tier/dev/terraform.tfstate
s3://company-terraform-state/lab5-standard-3-tier/staging/terraform.tfstate
s3://company-terraform-state/lab5-standard-3-tier/prod/terraform.tfstate
```

Khong nen de provider credentials trong code. Nen dung:

- AWS SSO
- IAM role
- OIDC cho GitHub Actions

## 10. Naming convention

Nen thong nhat:

- `${project}-${environment}-${component}`

Vi du:

- `lab5-dev-vpc`
- `lab5-prod-alb`
- `lab5-prod-app-asg`
- `lab5-prod-db`

Tag chung:

- `Project = lab5-standard-3-tier`
- `Environment = dev|staging|prod`
- `ManagedBy = terraform`
- `Owner = infra-team`
- `CostCenter = ...`

## 11. Phuong an toi uu thuc te cho repo nay

Neu dat trong boi canh "lam dung, de van hanh, khong qua phuc tap", toi de xuat:

### Phuong an nen dung ngay

- Giu AWS 3-tier.
- ALB public.
- EC2 ASG private app tier.
- RDS PostgreSQL private db tier.
- SSM thay SSH.
- S3 backend + DynamoDB lock.
- 1 NAT cho dev/staging, 2 NAT cho prod.
- WAF chi bat cho prod neu dich vu public.

### Chua can lam ngay

- Service mesh
- EKS
- Quá nhieu module nho gay phan manh
- Qua nhieu workspace thay cho tach root stack

## 12. Loi khuyen refactor theo giai doan

### Phase 1: Chuyen repo ve dung cau truc Terraform

- Doi `environments/` thanh `stacks/` hoac giu nguyen nhung to chuc lai dung chuan.
- Xoa provider mock khoi `modules/alb`.
- Dua ALB ra khoi `modules/ec2`.
- Sua toan bo module de nhan input va tra output dung boundary.
- Dien day du `providers.tf`, `versions.tf`, `variables.tf`, `outputs.tf` cho moi root stack.

### Phase 2: Dat baseline production

- Remote backend S3 + DynamoDB.
- Secrets Manager.
- ASG + Launch Template.
- HTTPS + ACM.
- RDS encryption + backup + deletion protection.
- CloudWatch alarms.

### Phase 3: Hardening va van hanh

- WAF.
- VPC endpoints.
- ALB access logs / VPC Flow Logs.
- Pipeline plan/apply.
- TFLint + tfsec/checkov + pre-commit.

## 13. Danh sach viec can sua ngay trong repo hien tai

Day la danh sach uu tien cao nhat:

1. Sua `module` path sai cua security group.
2. Xoa block `module "networking"` nam trong `modules/networking/main.tf`.
3. Tach ALB khoi `modules/ec2`.
4. Doi tat ca cross-module references thanh input/output.
5. Bo hard-coded secrets va provider credentials.
6. Bo sung root stack day du cho `staging` va `prod`.
7. Khai bao remote backend.
8. Chuyen EC2 don le sang ASG.
9. Hardening RDS.
10. Bo sung logging, alarms, CI/CD.

## 14. Ket luan

Infra hien tai la mot ban POC 3-tier, chua phai mot production baseline.

Neu lam theo huong de xuat trong tai lieu nay, repo se dat duoc 4 muc tieu quan trong:

- Deploy dung chuan Terraform.
- De mo rong va bao tri.
- An toan hon cho production.
- De team infra lam viec nhat quan giua dev, staging, prod.

Buoc tiep theo hop ly nhat la refactor repo theo cau truc moi, sau do implement lan luot `network -> security -> alb -> compute-asg -> rds -> observability`.
