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
# Variables - ECS
###############################################################################
variable "ecs_cluster_name" {
  description = "(Optional) The name of the ECS Cluster."
  default     = "ecs-cluster"
}

variable "ecs_service_name" {
  description = "(Optional) The name of the ECS Service and CloudMAP."
  default     = "ecs-demo"
}

variable "container_name" {
  description = "(Optional) The name of the ECS container."
  default     = "ecsdemo-frontend"
}

variable "container_port" {
  description = "(Optional) The port of the ECS container."
  default     = 3000
}

variable "container_image" {
  description = "(Required) The image of the ECS container."
  default     = null
}

###############################################################################
# Variables - Bastion Instance
###############################################################################
variable "bastion_ec2_name" {
  description = "(Optional) The name of the EC2 Instance."
  default     = "Ec2Instance"
}

variable "bastion_ec2_instance_type" {
  description = "(Optional) The Instance Type of the EC2 Instance."
  default     = "t2.small"
}

variable "bastion_ec2_key_pair" {
  description = "(Optional) The key pair to use to connect to the instance."
  default     = null
}

###############################################################################
# Variables - IAM Role (Streaming Server)
###############################################################################
variable "role_name" {
  type        = string
  description = "The IAM Role name. Conflicts with name_prefix. Choose either."
  default     = "jenkins"
}

variable "name_prefix" {
  type        = string
  description = "The IAM Role name prefix. Conflicts with name. Choose either."
  default     = null
}

variable "assume_role_policy" {
  description = "Assume Role Policy."
  default     = ""
}

variable "force_detach_policies" {
  type        = bool
  description = "Allow policy / policies to be forcibly detached."
  default     = false
}

variable "path" {
  description = "IAM Role path."
  default     = "/"
}

variable "description" {
  description = "IAM Role description."
  default     = "Managed by Terraform."
}

variable "policy_arn" {
  description = "List of policy ARNs to attached to the role."
  type        = list(string)
}

variable "principal_type" {
  type        = string
  description = "Principal type for trust identity."
  default     = "Service"
}

variable "principal_identifiers" {
  type        = list(string)
  description = "Principal identifier for trust identity."
  default     = ["ec2.amazonaws.com"]
}

###############################################################################
# Variables - Streaming Server ALB
###############################################################################
variable "internal" {
  type        = bool
  description = "Is the ALB internal?"
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  description = "Enable / Disable cross zone load balancing."
  default     = false
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Enable / Disable deletion protection for the ALB."
  default     = false
}

variable "svc_port" {
  type        = number
  description = "Service port: The port on which targets receive traffic."
  default     = 80
}

variable "target_group_protocol" {
  type        = string
  description = "The protocol to use to connect to the target."
  default     = "HTTP"
}

variable "healthy_threshold" {
  type        = number
  description = "ALB healthy count."
  default     = 2
}

variable "unhealthy_threshold" {
  type        = number
  description = "ALB unhealthy count."
  default     = 10
}

variable "timeout" {
  type        = number
  description = "ALB timeout value."
  default     = 5
}

variable "interval" {
  type        = number
  description = "ALB health check interval."
  default     = 20
}

variable "success_codes" {
  description = "Success Codes for the Target Group Health Checks. Default is 200 ( OK )."
  type        = string
  default     = "200"
}

variable "target_group_path" {
  type        = string
  description = "Health check request path."
  default     = "/login"
}

variable "target_group_port" {
  type        = number
  description = "The port to use to connect with the target."
  default     = "80"
}

variable "http_listener_required" {
  type        = bool
  description = "Enables / Disables creating HTTP listener. Listener auto redirects to HTTPS."
  default     = true
}

variable "listener1_alb_listener_port" {
  type        = number
  description = "HTTP listener port."
  default     = 80
}

variable "listener1_alb_listener_protocol" {
  type        = string
  description = "HTTP listener protocol."
  default     = "HTTP"
}

variable "alb_listener_port" {
  type        = number
  description = "ALB listener port."
  default     = "443"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the SSL certificate to use."
  default     = ""
}

variable "alb_listener_protocol" {
  type        = string
  description = "ALB listener protocol."
  default     = "HTTPS"
}

###############################################################################
# Variables - Launch Configuration (Streaming Server)
###############################################################################
variable "streaming_server_ec2_instance_type" {
  type        = string
  description = "The Jenkins instance type."
  default     = "t3a.medium"
}

variable "streaming_server_ec2_key_name" {
  type        = string
  description = "The key pair to use to connect to the Jenkins instance."
}

variable "enable_monitoring" {
  type        = bool
  description = "AutoScaling - enables/disables detailed monitoring."
  default     = "false"
}

variable "custom_userdata" {
  description = "Set custom userdata."
  type        = string
  default     = ""
}

variable "volume_size" {
  type        = number
  description = "ec2 volume size."
  default     = 30
}

variable "volume_type" {
  type        = string
  description = "ec2 volume type."
  default     = "gp2"
}

variable "encrypted" {
  type        = bool
  description = "Encryption of volumes."
  default     = true
}

variable "preliminary_user_data" {
  type        = string
  description = "Preliminary shell script commands for adding to user data.Runs at the beginning of userdata"
  default     = "#preliminary_user_data"
}

variable "supplementary_user_data" {
  type        = string
  description = "Supplementary shell script commands for adding to user data.Runs at the end of userdata."
  default     = "#supplementary_user_data"
}

variable "autoscaling_schedule_create" {
  type        = number
  description = "Allows for disabling of scheduled actions on ASG. Enabled by default."
  default     = 1
}

variable "scale_down_cron" {
  type        = string
  description = "The time when the recurring scale down action start. Cron format."
  default     = "0 0 * * SUN"
}

variable "scale_up_cron" {
  type        = string
  description = "The time when the recurring scale up action start.Cron format."
  default     = "30 0 * * SUN"
}

###############################################################################
# Variables - Autoscaling Group (Streaming Server)
###############################################################################
variable "max_size" {
  type        = number
  description = "AutoScaling Group max size."
  default     = 3
}

variable "min_size" {
  type        = number
  description = "AutoScaling Group min size."
  default     = 1
}

variable "desired_capacity" {
  type        = number
  description = "AutoScaling Group desired capacity."
  default     = 1
}

variable "health_check_grace_period" {
  type        = number
  description = "AutoScaling health check grace period."
  default     = 180
}

variable "health_check_type" {
  type        = string
  description = "AutoScaling health check type. EC2 or ELB."
  default     = "ELB"
}

###############################################################################
# Variables - Elasticsearch
###############################################################################
variable "create_iam_service_linked_role" {
  type        = bool
  default     = true
  description = "Whether to create `AWSServiceRoleForAmazonElasticsearchService` service-linked role. Set it to `false` if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exists. See https://github.com/terraform-providers/terraform-provider-aws/issues/5218 for more info"
}

variable "iam_role_max_session_duration" {
  type        = number
  default     = 3600
  description = "The maximum session duration (in seconds) for the user role. Can have a value from 1 hour to 12 hours"
}

variable "es_name" {
  type        = string
  description = "Name of the Elasticsearch domain."
  default     = "hoot"
}

variable "iam_authorizing_role_arns" {
  type        = list(string)
  default     = []
  description = "List of IAM role ARNs to permit to assume the Elasticsearch user role"
}

variable "aws_ec2_service_name" {
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
  description = "AWS EC2 Service Name"
}

variable "elasticsearch_version" {
  type        = string
  default     = "7.4"
  description = "Version of Elasticsearch to deploy (_e.g._ `7.4`, `7.1`, `6.8`, `6.7`, `6.5`, `6.4`, `6.3`, `6.2`, `6.0`, `5.6`, `5.5`, `5.3`, `5.1`, `2.3`, `1.5`"
}

variable "advanced_options" {
  type        = map(string)
  default     = {}
  description = "Key-value string pairs to specify advanced configuration options"
}

variable "advanced_security_options_enabled" {
  type        = bool
  default     = false
  description = "AWS Elasticsearch Kibana enchanced security plugin enabling (forces new resource)"
}

variable "advanced_security_options_internal_user_database_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable or not internal Kibana user database for ELK OpenDistro security plugin"
}

variable "advanced_security_options_master_user_arn" {
  type        = string
  default     = ""
  description = "ARN of IAM user who is to be mapped to be Kibana master user (applicable if advanced_security_options_internal_user_database_enabled set to false)"
}

variable "advanced_security_options_master_user_name" {
  type        = string
  default     = ""
  description = "Master user username (applicable if advanced_security_options_internal_user_database_enabled set to true)"
}

variable "advanced_security_options_master_user_password" {
  type        = string
  default     = ""
  description = "Master user password (applicable if advanced_security_options_internal_user_database_enabled set to true)"
}

variable "ebs_volume_size" {
  type        = number
  description = "EBS volumes for data storage in GB"
  default     = 0
}

variable "ebs_volume_type" {
  type        = string
  default     = "gp2"
  description = "Storage type of EBS volumes"
}

variable "ebs_iops" {
  type        = number
  default     = 0
  description = "The baseline input/output (I/O) performance of EBS volumes attached to data nodes. Applicable only for the Provisioned IOPS EBS volume type"
}

variable "encrypt_at_rest_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable encryption at rest"
}

variable "encrypt_at_rest_kms_key_id" {
  type        = string
  default     = ""
  description = "The KMS key ID to encrypt the Elasticsearch domain with. If not specified, then it defaults to using the AWS/Elasticsearch service KMS key"
}

variable "domain_endpoint_options_enforce_https" {
  type        = bool
  default     = true
  description = "Whether or not to require HTTPS"
}

variable "domain_endpoint_options_tls_security_policy" {
  type        = string
  default     = "Policy-Min-TLS-1-0-2019-07"
  description = "The name of the TLS security policy that needs to be applied to the HTTPS endpoint"
}

variable "custom_endpoint_enabled" {
  type        = bool
  description = "Whether to enable custom endpoint for the Elasticsearch domain."
  default     = false
}

variable "custom_endpoint" {
  type        = string
  description = "Fully qualified domain for custom endpoint."
  default     = ""
}

variable "custom_endpoint_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for custom endpoint."
  default     = ""
}

variable "elasticsearch_instance_type" {
  type        = string
  default     = "t2.small.elasticsearch"
  description = "Elasticsearch instance type for data nodes in the cluster"
}

variable "instance_count" {
  type        = number
  description = "Number of data nodes in the cluster"
  default     = 4
}

variable "dedicated_master_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether dedicated master nodes are enabled for the cluster"
}

variable "dedicated_master_count" {
  type        = number
  description = "Number of dedicated master nodes in the cluster"
  default     = 0
}

variable "dedicated_master_type" {
  type        = string
  default     = "t2.small.elasticsearch"
  description = "Instance type of the dedicated master nodes in the cluster"
}

variable "zone_awareness_enabled" {
  type        = bool
  default     = true
  description = "Enable zone awareness for Elasticsearch cluster"
}

variable "warm_enabled" {
  type        = bool
  default     = false
  description = "Whether AWS UltraWarm is enabled"
}

variable "warm_count" {
  type        = number
  default     = 2
  description = "Number of UltraWarm nodes"
}

variable "warm_type" {
  type        = string
  default     = "ultrawarm1.medium.elasticsearch"
  description = "Type of UltraWarm nodes"
}

variable "availability_zone_count" {
  type        = number
  default     = 2
  description = "Number of Availability Zones for the domain to use."
}

variable "node_to_node_encryption_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable node-to-node encryption"
}

variable "vpc_enabled" {
  type        = bool
  description = "Set to false if ES should be deployed outside of VPC."
  default     = true
}

variable "automated_snapshot_start_hour" {
  type        = number
  description = "Hour at which automated snapshots are taken, in UTC"
  default     = 0
}

variable "cognito_authentication_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable Amazon Cognito authentication with Kibana"
}

variable "cognito_user_pool_id" {
  type        = string
  default     = ""
  description = "The ID of the Cognito User Pool to use"
}

variable "cognito_identity_pool_id" {
  type        = string
  default     = ""
  description = "The ID of the Cognito Identity Pool to use"
}

variable "cognito_iam_role_arn" {
  type        = string
  default     = ""
  description = "ARN of the IAM role that has the AmazonESCognitoAccess policy attached"
}

variable "log_publishing_index_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for INDEX_SLOW_LOGS is enabled or not"
}

variable "log_publishing_index_cloudwatch_log_group_arn" {
  type        = string
  default     = ""
  description = "ARN of the CloudWatch log group to which log for INDEX_SLOW_LOGS needs to be published"
}

variable "log_publishing_search_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for SEARCH_SLOW_LOGS is enabled or not"
}

variable "log_publishing_search_cloudwatch_log_group_arn" {
  type        = string
  default     = ""
  description = "ARN of the CloudWatch log group to which log for SEARCH_SLOW_LOGS needs to be published"
}

variable "log_publishing_audit_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for AUDIT_LOGS is enabled or not"
}

variable "log_publishing_audit_cloudwatch_log_group_arn" {
  type        = string
  default     = ""
  description = "ARN of the CloudWatch log group to which log for AUDIT_LOGS needs to be published"
}

variable "log_publishing_application_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for ES_APPLICATION_LOGS is enabled or not"
}

variable "log_publishing_application_cloudwatch_log_group_arn" {
  type        = string
  default     = ""
  description = "ARN of the CloudWatch log group to which log for ES_APPLICATION_LOGS needs to be published"
}

variable "iam_actions" {
  type        = list(string)
  default     = []
  description = "List of actions to allow for the IAM roles, _e.g._ `es:ESHttpGet`, `es:ESHttpPut`, `es:ESHttpPost`"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the cluster"
}

###############################################################################
# Variables - S3 Bucket
###############################################################################
variable "bucket_name" {
  type        = string
  default     = ""
  description = "The name of the bucket."
}

variable "bucket_versioning" {
  type        = bool
  default     = true
  description = "(Optional) If S3 Bucket versioning is enabled or not."
}
