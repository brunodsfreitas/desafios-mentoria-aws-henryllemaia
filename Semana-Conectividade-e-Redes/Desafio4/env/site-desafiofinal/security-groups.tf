################################################################################
# Security Groups
################################################################################
module "sg_eice" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "${var.desc_tags.project}-sg-eice"
  description = "sg-eice"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "allow all (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "allow all out (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "sg_ecr_endpoint" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name                = "${var.desc_tags.project}-sg-ecr"
  description         = "sg-ecr"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "allow all (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "allow all out (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "sg_rds" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name                = "${var.desc_tags.project}-sg-rds"
  description         = "sg-ecr"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PGSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
}

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.ecs_name}-sg-autoscaling"
  description = "Autoscaling group security group"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "allow all (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "allow all out (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = var.desc_tags
}

module "bastion_host_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "bastion_host-sg"
  description = "bastion host security group"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  #egress_cidr_blocks  = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "allow all (ipv4)"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "allow all out (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = var.desc_tags
}
################################################################################
# Security Groups Rules
################################################################################
resource "aws_security_group_rule" "eiec_sg_rules" {
  count             = length(keys(data.external.get_ip_range_eiec.result))
  security_group_id = module.autoscaling_sg.security_group_id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [element(keys(data.external.get_ip_range_eiec.result), count.index)]
}