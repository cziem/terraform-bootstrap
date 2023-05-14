###############################################################################
# Outputs - VPC
###############################################################################
output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets."
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets."
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets."
  value       = module.vpc.database_subnets
}

output "database_subnet_group" {
  description = "ID of database subnet group."
  value       = module.vpc.database_subnet_group
}

###############################################################################
# Outputs - ECR
###############################################################################
output "repository_registry_id" {
  description = "The registry ID where the Repository is created."
  value       = module.ecr.repository_registry_id
}

output "repository_url" {
  description = "The URL of the Repository."
  value       = module.ecr.repository_url
}
