###############################################################################
# Environment
###############################################################################
aws_account_id = "130541009828"
region         = "ap-southeast-2"
environment    = "Development"

###############################################################################
# ECS
###############################################################################
ecs_service_name = "ecs-demo"
ecs_cluster_name = "ecs-cluster"
container_name   = "ecsdemo-frontend"
container_port   = 3000
container_image  = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"

###############################################################################
# EC2
###############################################################################
bastion_ec2_name          = "bastion-instance"
bastion_ec2_instance_type = "t3.micro"
bastion_ec2_key_pair      = "antonio-ap-mbp"

###############################################################################
# IAM Role - Added as a sample on how to add AWS Managed policy to the Streaming Server
###############################################################################
policy_arn = [
  "arn:aws:iam::aws:policy/AmazonS3FullAccess",
]

###############################################################################
# Streaming Server Launch Configuraion
###############################################################################
streaming_server_ec2_instance_type = "t3a.medium"
streaming_server_ec2_key_name      = "antonio-ap-mbp"

###############################################################################
# ALB - Added as a sample if you want to add in ACM certificate for HTTPS
###############################################################################
# certificate_arn = "arn:aws:acm:us-west-2:XXXXXXXXXXXX:certificate/1aa5c15f-c372-419d-a057-dac24e1XXXXXX"

###############################################################################
# Elasticsearch
###############################################################################
es_name                     = "es-cluster"
zone_awareness_enabled      = "true"
elasticsearch_version       = "7.9"
elasticsearch_instance_type = "t2.medium.elasticsearch"
instance_count              = 3
availability_zone_count     = 3
ebs_volume_size             = 10
iam_actions                 = ["es:ESHttpGet", "es:ESHttpPut", "es:ESHttpPost"]
encrypt_at_rest_enabled     = "false"
advanced_options = {
  "rest.action.multi.allow_explicit_index" = "true"
}

###############################################################################
# S3 Bucket
###############################################################################
bucket_name       = "my-s3-bucket-test-74328472"
bucket_versioning = true
