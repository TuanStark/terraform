# lab5-standard-3-tier

Production-ready Terraform skeleton for a standard AWS 3-tier architecture.

## What changed

This repository now contains a new production-oriented layout alongside the original proof-of-concept code:

- `modules/network`: VPC, subnets, NAT Gateway, route tables
- `modules/security`: security groups for ALB, app, and database tiers
- `modules/alb`: ALB, listeners, target group
- `modules/compute-asg`: launch template, EC2 IAM role, Auto Scaling Group
- `modules/rds-postgres`: PostgreSQL RDS with managed master password
- `stacks/dev`, `stacks/staging`, `stacks/prod`: root deployment units for each environment

The legacy `environments/` and older `modules/` folders are left in place for reference and migration.

## Suggested flow

1. Fill in real backend values in `stacks/<env>/backend.hcl`
2. Fill in real certificate ARN where HTTPS is required
3. Authenticate to AWS using SSO, IAM role, or OIDC
4. Initialize and plan the target stack

## PowerShell examples

```powershell
./scripts/init.ps1 -Environment dev
./scripts/plan.ps1 -Environment dev
./scripts/apply.ps1 -Environment dev
```

## Repository layout

```text
docs/
modules/
  alb/
  compute-asg/
  network/
  rds-postgres/
  security/
stacks/
  dev/
  staging/
  prod/
scripts/
.github/workflows/
```

## Important notes

- `stacks/dev` allows HTTP-only if `acm_certificate_arn = null`
- `stacks/staging` and `stacks/prod` are preconfigured for HTTPS placeholders
- `modules/rds-postgres` uses `manage_master_user_password = true` to avoid hard-coded credentials
- `prod` uses one NAT Gateway per AZ while `dev` and `staging` use a shared NAT by default

## Next improvements

- Add WAF and Route53 modules
- Add VPC endpoints for SSM, Secrets Manager, CloudWatch Logs, and S3
- Add observability module for alarms and dashboards
- Add policy checks with `tflint`, `tfsec`, and `checkov`
