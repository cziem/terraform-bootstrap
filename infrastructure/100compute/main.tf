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
    key     = "development.100compute.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

###############################################################################
# Data Source
###############################################################################
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket  = "XXXXXXXXXXXX-build-state-bucket-ecs-opensearch-environment"
    key     = "development.000base.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_ssm_parameter" "fluentbit" {
  name = "/aws/service/aws-for-fluent-bit/stable"
}

###############################################################################
# Locals
###############################################################################
locals {
  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr        = data.terraform_remote_state.network.outputs.vpc_cidr
  private_subnets = data.terraform_remote_state.network.outputs.private_subnets
  public_subnets  = data.terraform_remote_state.network.outputs.public_subnets

  tags = {
    Environment = var.environment
  }
  asg_tags = [{
    key                 = "Name"
    value               = "Streaming Server"
    propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    }
  ]
}

###############################################################################
# Security Groups (ALB ECS)
###############################################################################
module "security_group_alb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "ecs-alb-sg"
  description = "ECS Application Load Balancer security group"
  vpc_id      = local.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.tags
}

###############################################################################
# ALB (ECS)
###############################################################################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.4.0"

  load_balancer_type = "application"
  name               = "ecs-fargate-alb"

  vpc_id                = local.vpc_id
  subnets               = local.public_subnets
  create_security_group = false
  security_groups       = [module.security_group_alb.security_group_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      # action_type        = "forward"
    },
  ]

  target_groups = [
    {
      name_prefix      = "tg-"
      backend_protocol = "HTTP"
      backend_port     = var.container_port
      target_type      = "ip"
    }
  ]

  tags = local.tags
}

###############################################################################
# ECS
###############################################################################
module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = var.ecs_cluster_name

  tags = local.tags
}

resource "aws_service_discovery_http_namespace" "this" {
  name        = var.ecs_service_name
  description = "CloudMap namespace for the service."
  tags        = local.tags
}

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name        = var.ecs_service_name
  cluster_arn = module.ecs_cluster.arn

  cpu    = 1024
  memory = 4096

  # Container definition(s)
  container_definitions = {

    fluent-bit = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = nonsensitive(data.aws_ssm_parameter.fluentbit.value)
      firelens_configuration = {
        type = "fluentbit"
      }
      memory_reservation = 50
      user               = "0"
    }

    "${var.container_name}" = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = var.container_image
      port_mappings = [
        {
          name          = var.container_name
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      dependencies = [{
        containerName = "fluent-bit"
        condition     = "START"
      }]

      enable_cloudwatch_logging = false
      log_configuration = {
        logDriver = "awsfirelens"
        options = {
          Name                    = "firehose"
          region                  = var.region
          delivery_stream         = "my-stream"
          log-driver-buffer-limit = "2097152"
        }
      }
      memory_reservation = 100
    }
  }

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = {
      client_alias = {
        port     = var.container_port
        dns_name = var.container_name
      }
      port_name      = var.container_name
      discovery_name = var.container_name
    }
  }

  load_balancer = {
    service = {
      target_group_arn = element(module.alb.target_group_arns, 0)
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  subnet_ids = local.private_subnets
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.security_group_alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = local.tags
}

###############################################################################
# Security Groups (Bastion)
###############################################################################
module "security_group_bastion" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "bastion-sg"
  description = "Bastion security group"
  vpc_id      = local.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]

  egress_rules = ["all-all"]

  tags = local.tags
}

###############################################################################
# EC2 Instance (Bastion)
###############################################################################
module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.3.0"

  name          = var.bastion_ec2_name
  instance_type = var.bastion_ec2_instance_type
  key_name      = var.bastion_ec2_key_pair
  ami           = data.aws_ami.amazon-linux-2.id

  vpc_security_group_ids      = [module.security_group_bastion.security_group_id]
  subnet_id                   = local.public_subnets[0]
  associate_public_ip_address = true

  tags = local.tags
}

###############################################################################
# Security Groups (ALB Streaming Server)
###############################################################################
module "security_group_alb_streaming_server" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "streaming-server-alb-sg"
  description = "Security group for access to Streaming Server endpoint"
  vpc_id      = local.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]
}

###############################################################################
# Security Groups (Streaming Server)
###############################################################################
module "security_group_streaming_server_ec2" {
  depends_on = [module.security_group_alb_streaming_server]

  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "streaming-server-sg"
  description = "Security group for Streaming Server"
  vpc_id      = local.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = 6
      description              = "Streaming Server ALB"
      source_security_group_id = module.security_group_alb_streaming_server.security_group_id
    },
    # {
    #   from_port                = 22
    #   to_port                  = 22
    #   protocol                 = 6
    #   description              = "Bastion EC2"
    #   source_security_group_id = module.security_group_bastion.security_group_id
    # },
  ]

  egress_rules = ["all-all"]
}

###############################################################################
# Role, Profile and attachment (Streaming Server)
###############################################################################
data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = var.principal_type
      identifiers = var.principal_identifiers
    }
  }
}

resource "aws_iam_role" "this" {
  name                  = var.role_name != null ? var.role_name : null
  name_prefix           = var.name_prefix != null ? substr(var.name_prefix, 0, 22) : null
  assume_role_policy    = var.assume_role_policy == "" ? data.aws_iam_policy_document.this.json : var.assume_role_policy
  force_detach_policies = var.force_detach_policies
  path                  = var.path
  description           = var.description
}

resource "aws_iam_instance_profile" "this" {
  depends_on = [aws_iam_role.this]

  name        = var.role_name != null ? var.role_name : null
  name_prefix = var.name_prefix != null ? substr(var.name_prefix, 0, 22) : null
  path        = var.path
  role        = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "this" {
  count = length(var.policy_arn)

  role       = aws_iam_role.this.name
  policy_arn = var.policy_arn[count.index]
}

###############################################################################
# Find latest Amazon Linux AMI (Streaming Server)
###############################################################################
data "aws_ami" "latest_amazon_linux_ami" {
  most_recent = true

  #
  # 137112412989 - AWS
  # Beware of using anything other than this
  #
  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

###############################################################################
# Launch Config (Streaming Server)
###############################################################################
resource "aws_launch_configuration" "streaming_server" {
  name_prefix          = "terraform-streaming-server-lc-"
  image_id             = data.aws_ami.latest_amazon_linux_ami.id
  instance_type        = var.streaming_server_ec2_instance_type
  key_name             = var.streaming_server_ec2_key_name
  iam_instance_profile = aws_iam_instance_profile.this.name
  security_groups      = [module.security_group_streaming_server_ec2.security_group_id]
  enable_monitoring    = var.enable_monitoring
  user_data            = file("${path.module}/userdata.sh")

  # Setup root block device
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    encrypted   = var.encrypted
  }

  # Create before destroy
  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# Auto-Scaling Group (Streaming Server)
###############################################################################
resource "aws_autoscaling_group" "streaming_server" {
  depends_on = [aws_launch_configuration.streaming_server]

  name                      = "${var.environment}_streaming_server_asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  launch_configuration      = aws_launch_configuration.streaming_server.name
  vpc_zone_identifier       = [local.private_subnets[0], local.private_subnets[1], local.private_subnets[2]]
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  dynamic "tag" {
    for_each = local.asg_tags
    content {
      key                 = tag.value["key"]
      value               = tag.value["value"]
      propagate_at_launch = tag.value["propagate_at_launch"]
    }
  }
}

###############################################################################
# Streaming Server ALB
###############################################################################
resource "aws_lb" "streaming_server" {
  # only hyphens are allowed in name
  name = "streaming-server-alb"

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  internal                         = var.internal
  load_balancer_type               = "application"
  security_groups                  = [module.security_group_alb_streaming_server.security_group_id]
  subnets                          = local.public_subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = local.tags
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "tg-streaming-server"
  port     = var.svc_port
  protocol = var.target_group_protocol
  vpc_id   = local.vpc_id

  health_check {
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.timeout
    interval            = var.interval
    matcher             = var.success_codes

    path = var.target_group_path
    port = var.target_group_port
  }
}

# IF HTTPS IS ENABLED, REQUIRING ACM CERTIFICATE FOR HTTPS
# resource "aws_lb_listener" "l1_alb_listener" {
#   count             = var.http_listener_required ? 1 : 0
#   load_balancer_arn = aws_lb.streaming_server.arn
#   port              = var.listener1_alb_listener_port
#   protocol          = var.listener1_alb_listener_protocol
#
#   default_action {
#     type = "redirect"
#
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }
#
# resource "aws_alb_listener" "alb_listener" {
#   depends_on = [aws_autoscaling_group.jenkins]
#
#   load_balancer_arn = aws_lb.streaming_server.arn
#   port              = var.alb_listener_port
#   protocol          = var.alb_listener_protocol
#   certificate_arn   = var.certificate_arn
#
#   default_action {
#     target_group_arn = aws_lb_target_group.alb_target_group.arn
#     type             = "forward"
#   }
# }

resource "aws_alb_listener" "alb_listener" {
  depends_on = [aws_autoscaling_group.streaming_server]

  load_balancer_arn = aws_lb.streaming_server.arn
  port              = var.listener1_alb_listener_port
  protocol          = var.listener1_alb_listener_protocol

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    type             = "forward"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  depends_on = [aws_autoscaling_group.streaming_server]

  autoscaling_group_name = aws_autoscaling_group.streaming_server.id
  lb_target_group_arn    = aws_lb_target_group.alb_target_group.arn
}

###############################################################################
# Security Group (ElasticSearch)
###############################################################################
module "security_group_elasticsearch" {
  depends_on = [module.ecs_service]

  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "elasticsearch-sg"
  description = "Security group for ElasticSearch"
  vpc_id      = local.vpc_id

  ingress_cidr_blocks = [local.vpc_cidr]
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]
}

###############################################################################
# ElasticSearch
###############################################################################
module "elasticsearch" {
  source = "../../modules/elasticsearch"

  es_name                  = var.es_name
  existing_security_groups = [module.security_group_elasticsearch.security_group_id]
  subnet_ids               = local.private_subnets
  zone_awareness_enabled   = var.zone_awareness_enabled
  elasticsearch_version    = var.elasticsearch_version
  instance_type            = var.elasticsearch_instance_type
  instance_count           = var.instance_count
  ebs_volume_size          = var.ebs_volume_size
  iam_actions              = var.iam_actions
  encrypt_at_rest_enabled  = var.encrypt_at_rest_enabled
  availability_zone_count  = var.availability_zone_count
  advanced_options         = var.advanced_options
}

###############################################################################
# S3 Bucket
###############################################################################
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.10.1"

  bucket = var.bucket_name

  versioning = {
    enabled = var.bucket_versioning
  }
}
