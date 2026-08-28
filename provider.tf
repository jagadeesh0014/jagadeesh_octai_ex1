terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "jagadeesh-terraform-state-837567124319"
    key    = "exercise-1/vpc-ec2-rds-alb/terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "8byte-Exercise-1"
      Owner       = "jagadeesh"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}