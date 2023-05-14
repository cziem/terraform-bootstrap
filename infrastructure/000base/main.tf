###############################################################################
# Providers
###############################################################################
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

###############################################################################
# Terraform main config
###############################################################################
terraform {
  required_version = ">= 1.1.5"
  required_providers {
    aws = ">= 4.7"
  }
  backend "s3" {
    bucket  = "XXXXXXXXXXXX-build-state-bucket-ecs-opensearch-environment"
    key     = "development.000base.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

###############################################################################
# Data Source
###############################################################################
data "aws_availability_zones" "available" {}

###############################################################################
# Locals
###############################################################################
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Environment = var.environment
  }
}

###############################################################################
# VPC
###############################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  ### NAT Gateways

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  ### DNS Hostnames

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

###############################################################################
# ECR
###############################################################################
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"

  repository_name                 = var.ecr_repo_name
  repository_force_delete         = true
  create_repository_policy        = true
  repository_image_tag_mutability = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.tags
}
