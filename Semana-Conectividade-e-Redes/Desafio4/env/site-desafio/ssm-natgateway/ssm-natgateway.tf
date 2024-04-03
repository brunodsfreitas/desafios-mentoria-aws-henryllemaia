terraform {
  backend "local" {
    path = "terraform-prod.tfstate"
  }
}

module "vpc_ssm" {
  source = "../../modules/vpc"

  name = "${var.desc_tags.project}-vpc-ssm-private"
  cidr = var.vpc2_cidr_block

  azs             = var.subnet_availability_zones
  private_subnets = var.vpc2_private_subnets
  public_subnets  = var.vpc2_public_subnets

  tags = var.desc_tags

  default_vpc_enable_dns_support                             = true
  default_vpc_enable_dns_hostnames                           = true
  enable_nat_gateway                                         = true
  enable_vpn_gateway                                         = false
  single_nat_gateway                                         = true
  one_nat_gateway_per_az                                     = true
  public_dedicated_network_acl                               = false
  private_dedicated_network_acl                              = false
  map_public_ip_on_launch                                    = true
  intra_subnet_enable_resource_name_dns_a_record_on_launch   = false
  public_subnet_enable_resource_name_dns_a_record_on_launch  = true
  private_subnet_enable_resource_name_dns_a_record_on_launch = true
}

module "sg_ec2_ssm" {
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg2_name}"
  description = var.sg2_description
  vpc_id      = module.vpc_ssm.vpc_id

  ingress_cidr_blocks      = [module.vpc_ssm.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg2_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg2_egress_with_cidr_blocks1
}

module "ec2_ssm" {
  source                 = "../../modules/ec2"
  vpc_security_group_ids = [module.sg_ec2_ssm.security_group_id]
  name                   = "${var.desc_tags.project}-${var.ec2_2_name}"
  instance_type          = var.ec2_2_instance_type
  key_name               = var.ec2_2_key_name
  monitoring             = false
  subnet_id              = module.vpc_ssm.private_subnets[0]
  iam_instance_profile   = var.ec2_2_iam_instance_profile

  tags = var.desc_tags
}
