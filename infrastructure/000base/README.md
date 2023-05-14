# Initialisation

This layer is used to setup the Network VPC and ECR.

# Pre-requisite

- AWS_ACCESS_KEYS and AWS_SECRET_ACCESS_KEYS are set as environment variables (link: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
- Terraform version > 1.1.5 (version 1.3.7 suggested)

### Create

Update the `terraform.tfvars` file to include the required `aws_account_id`. Optional variables are: `environment` and `region`.

- update terraform.tfvars with your `aws_account_id`.

```bash
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

### Destroy

```bash
$ terraform destroy
```

## Inputs for Account / Environment

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | (Required) The AWS Account ID. | string | `null` | yes |
| region | (Optional) Region where resources will be created. | string | `eu-west-2` | no |
| environment | (Optional) The name of the environment, e.g. Production, Development, etc. | string | `Development` | no |

## Inputs for VPC

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| vpc\_name | (Optional) Name to be used on all the resources as identifier. | string | `null` | no |
| vpc\_cidr | (Optional) CIDR range for the VPC. | string | `10.0.0.0/16` | no |
| private\_subnets | (Optional) A list of private subnets inside the VPC. | list | `["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]` | no |
| public\_subnets | (Optional) A list of public subnets inside the VPC. | list | `["10.0.48.0/24", "10.0.49.0/24", "10.0.50.0/24"]` | no |
| database\_subnets | (Optional) A list of database subnets inside the VPC. | list | `["10.0.52.0/24", "10.0.53.0/24", "10.0.54.0/24"]` | no |
| single\_nat\_gateway | (Optional) Should be true if you want to provision a single shared NAT Gateway across all of your private networks. | bool | `true` | no |

## Inputs for ECR

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ecr\_repo\_name\_1 | (Optional) Name of the repository 1. | string | `"repo-1"` | no |
| ecr\_repo\_name\_2 | (Optional) Name of the repository 2. | string | `"repo-2"` | no |

## Outputs for VPC

| Name | Description |
|------|-------------|
| vpc\_id | The ID of the VPC. |
| vpc\_cidr | The CIDR block of the VPC. |
| private\_subnets | List of IDs of private subnets. |
| public\_subnets | List of IDs of public subnets. |
| database\_subnets | List of IDs of private subnets. |
| database\_subnet\_group | ID of database subnet group. |

## Outputs

| Name | Description |
|------|-------------|
| repository\_registry\_id | The registry ID where the Repository is created. |
| repository\_url | The URL of the Repository. |
