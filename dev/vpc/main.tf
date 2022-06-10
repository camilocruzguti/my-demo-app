#DATA#
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_caller_identity" "current" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "cacruz-my-demo-app-vpc"
    key    = "terraform/state.tfstate"
    region = "us-east-1"
  }

}

provider "aws" {
  region = var.aws_region
}


#
# VPC
#
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  cidr               = "10.0.0.0/16"
  azs                = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = merge(local.tags, {
    Name = "${var.base_name}-${local.environment_name}-vpc"
  })
}
