variable "aws_region" {
  default = "ap-south-1"
}

variable "project_name" {
  default = "8byte-ex1"
}

variable "environment" {
  default = "dev"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t3.small" 
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
  default     = "Password123!"
}