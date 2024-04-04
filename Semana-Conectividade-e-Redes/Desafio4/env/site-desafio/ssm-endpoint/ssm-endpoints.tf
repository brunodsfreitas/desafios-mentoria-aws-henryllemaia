terraform {
  backend "local" {
    path = "terraform-prod.tfstate"
  }
}

module "vpc_ssm_endpoints" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = "${var.desc_tags.project}-vpc-ssm-endpoints"
  cidr = var.vpc4_cidr_block

  azs             = var.subnet_availability_zones
  public_subnets  = var.vpc4_public_subnets
  private_subnets = var.vpc4_private_subnets

  tags = var.desc_tags

  default_vpc_enable_dns_support                             = true
  default_vpc_enable_dns_hostnames                           = true
  enable_nat_gateway                                         = false
  enable_vpn_gateway                                         = false
  single_nat_gateway                                         = false
  one_nat_gateway_per_az                                     = false
  public_dedicated_network_acl                               = false
  private_dedicated_network_acl                              = false
  map_public_ip_on_launch                                    = true
  intra_subnet_enable_resource_name_dns_a_record_on_launch   = false
  public_subnet_enable_resource_name_dns_a_record_on_launch  = true
  private_subnet_enable_resource_name_dns_a_record_on_launch = true
}

module "sg_endpoints" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "${var.desc_tags.project}-sg-${var.sg5_name}"
  description = var.sg5_description
  vpc_id      = module.vpc_ssm_endpoints.vpc_id

  ingress_cidr_blocks      = [module.vpc_ssm_endpoints.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg5_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg5_egress_with_cidr_blocks1
}

### VPC ENDPOINTS
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = module.vpc_ssm_endpoints.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [module.sg_endpoints.security_group_id]
  subnet_ids         = [module.vpc_ssm_endpoints.private_subnets[0]] #apenas na az1

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id            = module.vpc_ssm_endpoints.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [module.sg_endpoints.security_group_id]
  subnet_ids         = [module.vpc_ssm_endpoints.private_subnets[0]] #apenas na az1

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id            = module.vpc_ssm_endpoints.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [module.sg_endpoints.security_group_id]
  subnet_ids         = [module.vpc_ssm_endpoints.private_subnets[0]] #apenas na az1

  private_dns_enabled = true
}

module "sg_ec2_ssm_endpoints" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "${var.desc_tags.project}-sg-${var.sg6_name}"
  description = var.sg6_description
  vpc_id      = module.vpc_ssm_endpoints.vpc_id

  ingress_cidr_blocks      = [module.vpc_ssm_endpoints.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg6_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg6_egress_with_cidr_blocks1
}

module "ec2_ssm_endpoints" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"
  vpc_security_group_ids = [module.sg_ec2_ssm_endpoints.security_group_id]
  name                   = "${var.desc_tags.project}-${var.ec2_4_name}"
  instance_type          = var.ec2_4_instance_type
  key_name               = var.ec2_4_key_name
  monitoring             = false
  subnet_id              = module.vpc_ssm_endpoints.private_subnets[0]
  iam_instance_profile   = var.ec2_4_iam_instance_profile

  tags = var.desc_tags
}
