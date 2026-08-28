# Exercise-1: AWS Infrastructure with Terraform - 8byte

This project provisions a complete AWS infrastructure using Terraform including VPC, EC2, ALB, and RDS.

---

## 1. How to Set Up and Run the Infrastructure

### Prerequisites

- AWS CLI configured with valid credentials
- Terraform >= 1.5
- IAM permissions for EC2, VPC, RDS, ALB, and S3

### Deployment Steps

```bash
git clone <your-repo-url>
cd exercise-1

terraform init
terraform plan
terraform apply -auto-approve

terraform output
```

After deployment, copy the `alb_url` from the output and open it in your browser.

Expected output:

```text
Hi from 8byte - Exercise-1 Success!
```

### To Destroy Infrastructure

```bash
terraform destroy -auto-approve
```

---

## 2. Architecture Overview

### Network

- VPC: `10.0.0.0/16`
- 2 Public Subnets across 2 Availability Zones
- 2 Private Subnets across 2 Availability Zones

### Connectivity

- Internet Gateway attached to VPC
- Public subnet route tables configured with route to Internet Gateway

### Load Balancer

- Internet-facing Application Load Balancer (ALB)
- Target Group configured with health checks

### Compute

- 2 × `t3.micro` Amazon Linux 2 EC2 instances
- Nginx installed and configured through `user_data`

### Database

- MySQL RDS (`t3.micro`)
- Deployed in private subnets
- `publicly_accessible = false`

### Traffic Flow

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

### 2 AZs for High Availability

Provides fault tolerance and improved availability.

### ALB over Classic Load Balancer

- Better Layer 7 routing
- Advanced health checks
- Improved scalability

### Amazon Linux 2

- Lightweight operating system
- Native AWS integration
- Supports AWS Systems Manager (SSM)

### Public EC2 Instances (As Per Requirement)

For demonstration purposes EC2 instances are deployed in public subnets.

> In production environments, EC2 instances should be placed in private subnets.

### S3 Backend

Terraform state is stored in S3 for team collaboration and centralized state management.

---

## 4. Security Considerations

### Security Groups

**ALB Security Group**

- Allow HTTP (80) from `0.0.0.0/0`

**EC2 Security Group**

- Allow HTTP (80) only from ALB Security Group

**RDS Security Group**

- Allow MySQL (3306) only from EC2 Security