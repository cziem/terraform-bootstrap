# Initialisation

This layer is used to create the Compute resources (ECS, EC2, ElasticSearch, and S3 resources).

# Pre-requisite

- A valid AWS profile ready to use via CLI
- Terraform version > 1.1.5 (version 1.3.7 suggested)

### Create

Update the `terraform.tfvars` file to include the required `aws_account_id` and `container_image`. Optional variables are: `environment` and `region`.

```bash
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

### Destroy

```bash
$ terraform destroy
```

When prompted, check the plan and then respond in the affirmative.

## Inputs for Account / Environment

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | (Required) The AWS Account ID. | string | `null` | yes |
| region | (Optional) Region where resources will be created. | string | `eu-west-2` | no |
| environment | (Optional) The name of the environment, e.g. Production, Development, etc. | string | `Development` | no |

## Inputs for ECS

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ecs\_cluster\_name | (Optional) The name of the ECS Cluster. | string | `"ecs-cluster"` | no |
| ecs\_service\_name | (Optional) The name of the ECS Service and CloudMAP. | string | `"ecs-demo"` | no |
| container\_name | (Optional) The name of the ECS container. | string | `"ecsdemo-frontend"` | no |
| container\_port | (Optional) The port of the ECS container. | number | `3000` | no |
| container\_image | (Required) The image of the ECS container. | string | `null` | no |

## Inputs for the Bastion

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion\_ec2\_name | (Optional) The name of the EC2 Instance. | string | `"Ec2Instance"` | no |
| bastion\_ec2\_instance\_type | (Optional) The Instance Type of the EC2 Instance. | string | `"t2.small"` | no |
| bastion\_ec2\_key\_pair | (Optional) The key pair to use to connect to the instance. | string | `null` | yes |

## Inputs for the Streaming server

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| streaming\_server\_ec2\_instance\_type | (Optional) The Jenkins instance type. | string | `"t3a.medium"` | no |
| streaming\_server\_ec2\_key\_name | (Optional) The key pair to use to connect to the Jenkins instance. | string | `null` | yes |

## Inputs for Elasticsearch

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_iam\_service\_linked\_role | Whether to create `AWSServiceRoleForAmazonElasticsearchService` service-linked role. Set it to `false` if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exists. See https://github.com/terraform-providers/terraform-provider-aws/issues/5218 for more info | `bool` | `true` | no |
| iam\_role\_max\_session\_duration | The maximum session duration (in seconds) for the user role. Can have a value from 1 hour to 12 hours | `number` | `3600` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| es\_name | Name of the Elasticsearch domain. | `string` | `hoot` | no |
| iam\_authorizing\_role\_arns | List of IAM role ARNs to permit to assume the Elasticsearch user role | `list(string)` | `[]` | no |
| iam\_role\_arns | List of IAM role ARNs to permit access to the Elasticsearch domain | `list(string)` | `[]` | no |
| aws\_ec2\_service\_name | AWS EC2 Service Name | `list(string)` | `["ec2.amazonaws.com"]` | no |
| elasticsearch\_version | Version of Elasticsearch to deploy (\_e.g.\_ `7.4`, `7.1`, `6.8`, `6.7`, `6.5`, `6.4`, `6.3`, `6.2`, `6.0`, `5.6`, `5.5`, `5.3`, `5.1`, `2.3`, `1.5` | `string` | `7.4` | no |
| advanced\_options | Key-value string pairs to specify advanced configuration options | `map(string)` | `{}` | no |
| advanced\_security\_options\_enabled | AWS Elasticsearch Kibana enchanced security plugin enabling (forces new resource) | `bool` | `false` | no |
| advanced\_security\_options\_internal\_user\_database\_enabled | Whether to enable or not internal Kibana user database for ELK OpenDistro security plugin | `bool` | `false` | no |
| advanced\_security\_options\_master\_user\_arn | ARN of IAM user who is to be mapped to be Kibana master user (applicable if advanced\_security\_options\_internal\_user\_database\_enabled set to false) | `string` | `""` | no |
| advanced\_security\_options\_master\_user\_name | Master user username (applicable if advanced\_security\_options\_internal\_user\_database\_enabled set to true) | `string` | `""` | no |
| advanced\_security\_options\_master\_user\_password | Master user password (applicable if advanced\_security\_options\_internal\_user\_database\_enabled set to true) | `string` | `""` | no |
| ebs\_volume\_size | EBS volumes for data storage in GB | `number` | `0` | no |
| ebs\_volume\_type | Storage type of EBS volumes | `string` | `gp2` | no |
| ebs\_iops | The baseline input/output (I/O) performance of EBS volumes attached to data nodes. Applicable only for the Provisioned IOPS EBS volume type | `number` | `0` | no |
| encrypt\_at\_rest\_enabled | Whether to enable encryption at rest | `bool` | `true` | no |
| encrypt\_at\_rest\_kms\_key\_id | The KMS key ID to encrypt the Elasticsearch domain with. If not specified, then it defaults to using the AWS/Elasticsearch service KMS key | `string` | `""` | no |
| domain\_endpoint\_options\_enforce\_https | Whether or not to require HTTPS | `bool` | `true` | no |
| domain\_endpoint\_options\_tls\_security\_policy | The name of the TLS security policy that needs to be applied to the HTTPS endpoint | `string` | `"Policy-Min-TLS-1-0-2019-07"` | no |
| custom\_endpoint\_enabled | Whether to enable custom endpoint for the Elasticsearch domain. | `bool` | `false` | no |
| custom\_endpoint | Fully qualified domain for custom endpoint. | `string` | `""` | no |
| custom\_endpoint\_certificate\_arn | ACM certificate ARN for custom endpoint. | `string` | `""` | no |
| instance\_type | Elasticsearch instance type for data nodes in the cluster | `string` | `"t2.small.elasticsearch"` | no |
| instance\_count | Number of data nodes in the cluster. | `number` | `4` | no |
| dedicated\_master\_enabled | Indicates whether dedicated master nodes are enabled for the cluster. | `bool` | `false` | no |
| dedicated\_master\_count | Number of dedicated master nodes in the cluster. | `number` | `0` | no |
| dedicated\_master\_type | Instance type of the dedicated master nodes in the cluster | `string` | `"t2.small.elasticsearch"` | no |
| zone\_awareness\_enabled | Enable zone awareness for Elasticsearch cluster. | `bool` | `true` | no |
| warm\_enabled | Whether AWS UltraWarm is enabled. | `bool` | `false` | no |
| warm\_count | Number of UltraWarm nodes. | `number` | `2` | no |
| warm\_type | Type of UltraWarm nodes. | `string` | `"ultrawarm1.medium.elasticsearch"` | no |
| availability\_zone\_count | Number of Availability Zones for the domain to use. | `number` | `2` | no |
| node\_to\_node\_encryption\_enabled | Whether to enable node-to-node encryption. | `bool` | `false` | no |
| vpc\_enabled | Set to false if ES should be deployed outside of VPC. | `bool` | `true` | no |
| existing\_security\_groups | List of existing Security Group IDs to place the Elasticsearch domain into. | `list(string)` | `[]` | yes |
| vpc\_enabled | Set to false if ES should be deployed outside of VPC. | `list(string)` | `[]` | no |
| subnet\_ids | VPC Subnet IDs.  `list(string)` | `[]` | no |
| automated\_snapshot\_start\_hour | Hour at which automated snapshots are taken, in UTC | `number` | `0` | no |
| cognito\_authentication\_enabled | Whether to enable Amazon Cognito authentication with Kibana. | `bool` | `false` | no |
| cognito\_user\_pool\_id | The ID of the Cognito User Pool to use. | `string` | `""` | no |
| cognito\_identity\_pool\_id | The ID of the Cognito Identity Pool to use | `string` | `""` | no |
| cognito\_iam\_role\_arn | ARN of the IAM role that has the AmazonESCognitoAccess policy attached. | `string` | `""` | no |
| log\_publishing\_index\_enabled | Specifies whether log publishing option for INDEX\_SLOW\_LOGS is enabled or not. | `bool` | `false` | no |
| log\_publishing\_index\_cloudwatch\_log\_group\_arn | ARN of the CloudWatch log group to which log for INDEX\_SLOW\_LOGS needs to be published. | `string` | `""` | no |
| log\_publishing\_search\_enabled | Specifies whether log publishing option for SEARCH\_SLOW\_LOGS is enabled or not | `bool` | `false` | no |
| log\_publishing\_search\_cloudwatch\_log\_group\_arn | ARN of the CloudWatch log group to which log for SEARCH\_SLOW\_LOGS needs to be published. | `string` | `""` | no |
| log\_publishing\_audit\_enabled | Specifies whether log publishing option for AUDIT\_LOGS is enabled or not | `bool` | `false` | no |
| log\_publishing\_audit\_cloudwatch\_log\_group\_arn | ARN of the CloudWatch log group to which log for AUDIT\_LOGS needs to be published. | `string` | `""` | no |
| log\_publishing\_application\_enabled | Specifies whether log publishing option for ES\_APPLICATION\_LOGS is enabled or not | `bool` | `false` | no |
| log\_publishing\_application\_cloudwatch\_log\_group\_arn | ARN of the CloudWatch log group to which log for ES\_APPLICATION\_LOGS needs to be published. | `string` | `""` | no |
| iam\_actions | List of actions to allow for the IAM roles, \_e.g.\_ `es:ESHttpGet`, `es:ESHttpPut`, `es:ESHttpPost` | `list(string)` | `[]` | no |
| allowed\_cidr\_blocks | List of CIDR blocks to be allowed to connect to the cluster. | `list(string)` | `[]` | no |

## Inputs for the S3 Bucket

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name | (Required) The name of the bucket. | string | `""` | yes |
| bucket\_versioning | (Optional) If S3 Bucket versioning is enabled or not. | string | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecs\_alb\_dns | The DNS name of the ECS load balancer. |
| streaming\_server\_alb\_dns | The DNS name of the Streaming Server load balancer. |
| bastion\_public\_ip | The public IP address assigned to the Bastion instance. |
