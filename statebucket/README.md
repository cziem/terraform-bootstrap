# Initialisation

This layer is used to create a S3 bucket for remote state storage.

# Pre-requisite

A valid AWS profile ready to use via CLI.

### Create

Update terraform.tfvars with your `aws_account_id`, Optionally: `environent` and `region`

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | (Required) The AWS Account ID. | string | n/a | yes |
| region | (Optional) Region where resources will be created. | string | `us-east-1` | no |
| environment | (Optional) The name of the environment, e.g. Production, Development, etc. | string | `Development` | no |

## Outputs

| Name | Description |
|------|-------------|
| state\_bucket\_id | The ID of the bucket to be used for state files. |
| state\_bucket\_region | The region the state bucket resides in. |
