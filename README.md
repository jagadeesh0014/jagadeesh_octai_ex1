# Exercise-1: AWS Infrastructure with Terraform - 8byte

This project provisions a complete AWS infrastructure on AWS using Terraform, including:

- VPC
- Public and Private Subnets
- Application Load Balancer (ALB)
- EC2 Instances
- RDS MySQL Database
- S3 Backend for Terraform State Management

---

## 1. How to Set Up and Run the Infrastructure

### Prerequisites

- AWS CLI configured with valid credentials
- Terraform >= 1.5
- IAM permissions for:
  - EC2
  - VPC
  - RDS
  - ALB
  - S3
- Create an S3 bucket to store the Terraform state (terraform.tfstate) file and enable versioning to maintain state history and support recovery from accidental changes.


### Deployment Steps

```bash
git clone https://github.com/jagadeesh0014/jagadeesh_octai_ex1.git
cd jagadeesh_octai_ex1

terraform init
terraform plan
terraform apply -auto-approve

terraform output
```

After deployment, copy the `alb_url` from the Terraform output and open it in your browser.

Expected response:

```text
Hi from 8byte - Exercise-1 Success!
```

### Destroy Infrastructure

```bash
terraform destroy -auto-approve
```

---

## 2. Architecture Overview

### Network

- VPC CIDR: `10.0.0.0/16`
- 2 Public Subnets across 2 Availability Zones
- 2 Private Subnets across 2 Availability Zones

### Internet Access

- Internet Gateway attached to VPC
- Public route tables configured with routes to the Internet Gateway

### Load Balancer

- Internet-facing Application Load Balancer (ALB)
- Target Group configured with health checks

### Compute Layer

- 2 × EC2 instances (`t3.micro`)
- Amazon Linux 2
- Nginx installed using `user_data`

### Database Layer

- MySQL RDS (`t3.micro`)
- Deployed in private subnets
- `publicly_accessible = false`

### Terraform Backend

- S3 bucket stores the Terraform state (`terraform.tfstate`) file
- Bucket versioning enabled to maintain state history and support recovery

### Request Flow

```text
User
  ↓
ALB (Port 80)
  ↓
Target Group
  ↓
EC2 Instances (Nginx)
  ↓
RDS MySQL (Port 3306)
```

---

## 3. Architecture Decisions

### Multi-AZ Network Design

Two Availability Zones are used to improve availability and fault tolerance.

### ALB over Classic Load Balancer

- Layer 7 routing support
- Better health checks
- Improved scalability and flexibility

### Amazon Linux 2

- Lightweight AWS-optimized operating system
- Supports AWS Systems Manager (SSM)

### Public EC2 Instances

EC2 instances are deployed in public subnets as part of the exercise requirements.

> In production environments, EC2 instances should be placed in private subnets.

### S3 Backend

Terraform state is stored in an S3 bucket with versioning enabled for:

- Team collaboration
- State recovery
- Version tracking

---

## 4. Security Considerations

### Security Groups

#### ALB Security Group

- Allow HTTP (Port 80) from `0.0.0.0/0`

#### EC2 Security Group

- Allow HTTP (Port 80) only from the ALB Security Group

#### RDS Security Group

- Allow MySQL (Port 3306) only from the EC2 Security Group

### Private RDS

- Database is not publicly accessible

### SSM Session Manager

- No SSH access required
- Port 22 remains closed

### IMDSv2 Enabled

- Protects against SSRF attacks
- Enhances EC2 metadata security

---

## 5. Cost Optimization Measures

### Instance Types

- EC2: `t3.micro`
- RDS: `t3.micro`

Both are Free Tier eligible.

### No NAT Gateway

NAT Gateway was not created because it was unnecessary for this exercise, saving approximately **$30/month**.

### Single-AZ RDS

Multi-AZ deployment is disabled to reduce development costs.

### Resource Cleanup

Infrastructure can be destroyed after testing or demonstration to avoid ongoing charges.

---

## 6. Best Practices Implementation

### A. Secret Management

#### Current Implementation

For simplicity, the database password is passed through Terraform variables:

```hcl
var.db_password
```

#### Production Recommendation

Use AWS Secrets Manager instead of storing secrets in Terraform variables or state files.

Example:

```hcl
data "aws_secretsmanager_secret_version" "db_pass" {
  secret_id = "8byte-ex1-db-pass"
}

password = jsondecode(
  data.aws_secretsmanager_secret_version.db_pass.secret_string
)["password"]
```

### B. Backup Strategy

RDS automated backups are configured as follows:

```hcl
backup_retention_period   = 7
skip_final_snapshot       = false
final_snapshot_identifier = "8byte-ex1-final-snap"
```

This ensures:

- 7 days of automated backup retention
- Final snapshot creation before database deletion

---

## Challenges Faced & Resolutions

### 1. ALB Targets Unhealthy

**Issue:**

Nginx service was not installed correctly and targets failed health checks.

**Resolution:**

Updated `user_data` to install Nginx using:

```bash
amazon-linux-extras install nginx1 -y
```

### 2. Terraform Validation Human Error

**Issue:**

Incorrect configuration:

```hcl
unhealthy_threshold = 5ye
```

**Resolution:**

Corrected to:

```hcl
unhealthy_threshold = 5
```

### 3. user_data Changes Not Applied

**Issue:**

Terraform does not automatically recreate EC2 instances when only `user_data` changes.

**Resolution:**

Recreated instances using:

```bash
terraform apply -replace="aws_instance.web[0]"
```

---

## Outputs

The following outputs are exposed after deployment:

- ALB DNS Name
- VPC ID
- RDS Endpoint

---

## Summary

This Terraform project provisions a scalable AWS infrastructure consisting of:

- VPC with Public and Private Subnets
- Internet Gateway and Route Tables
- Application Load Balancer
- EC2 Instances Running Nginx
- MySQL RDS Database
- S3 Backend with Versioning for Terraform State

The solution demonstrates Infrastructure as Code (IaC) best practices while balancing security, cost optimization, maintainability, and availability.