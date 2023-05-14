###############################################################################
# Variables - Environment
###############################################################################
variable "aws_account_id" {
  description = "(Required) The AWS Account ID."
  default     = null
}

variable "region" {
  description = "(Optional) Region where resources will be created."
  default     = "eu-west-2"
}

variable "environment" {
  description = "(Optional) The name of the environment, e.g. Production, Development, etc."
  default     = "Development"
}

###############################################################################
# Variables - VPC
###############################################################################
variable "vpc_name" {
  description = "(Optional) Name to be used on all the resources as identifier."
  default     = "Terraform-VPC"
}

variable "vpc_cidr" {
  description = "(Optional) CIDR range for the VPC."
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "(Optional) A list of private subnets inside the VPC."
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "public_subnets" {
  description = "(Optional) A list of public subnets inside the VPC."
  default     = ["10.0.48.0/24", "10.0.49.0/24", "10.0.50.0/24"]
}

variable "database_subnets" {
  description = "(Optional) A list of database subnets."
  default     = ["10.0.52.0/24", "10.0.53.0/24", "10.0.54.0/24"]
}

variable "single_nat_gateway" {
  description = "(Optional) Should be true if you want to provision a single shared NAT Gateway across all of your private networks."
  default     = true
}

###############################################################################
# Variables - ECR
###############################################################################
variable "ecr_repo_name" {
  description = "(Optional) Name of the ECR repository."
  default     = "repo-1"
}
