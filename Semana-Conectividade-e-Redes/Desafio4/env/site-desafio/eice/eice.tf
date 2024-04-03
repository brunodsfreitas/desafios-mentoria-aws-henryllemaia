terraform {
  backend "local" {
    path = "terraform-prod.tfstate"
  }
}

module "vpc_eice" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = "${var.desc_tags.project}-vpc-eice"
  cidr = var.vpc_cidr_block

  azs           = var.subnet_availability_zones
  intra_subnets = var.intra_subnets

  tags = var.desc_tags

  default_vpc_enable_dns_support                             = true
  default_vpc_enable_dns_hostnames                           = true
  enable_nat_gateway                                         = false
  enable_vpn_gateway                                         = false
  single_nat_gateway                                         = false
  one_nat_gateway_per_az                                     = true
  public_dedicated_network_acl                               = false
  private_dedicated_network_acl                              = false
  map_public_ip_on_launch                                    = true
  intra_subnet_enable_resource_name_dns_a_record_on_launch   = true
  public_subnet_enable_resource_name_dns_a_record_on_launch  = true
  private_subnet_enable_resource_name_dns_a_record_on_launch = true
}

module "sg_instance_connect_endpoint" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "${var.desc_tags.project}-sg-${var.sg4_name}"
  description = var.sg4_description
  vpc_id      = module.vpc_eice.vpc_id

  ingress_cidr_blocks = [module.vpc_eice.vpc_cidr_block]
  #ingress_with_cidr_blocks = var.sg4_ingress_with_cidr_blocks1
  egress_with_cidr_blocks = var.sg4_egress_with_cidr_blocks1
}

resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id          = module.vpc_eice.intra_subnets[0]
  security_group_ids = [module.sg_instance_connect_endpoint.security_group_id]
}

module "sg_ec2_eice" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "${var.desc_tags.project}-sg-${var.sg1_name}"
  description = var.sg1_description
  vpc_id      = module.vpc_eice.vpc_id

  ingress_cidr_blocks      = [module.vpc_eice.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg1_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg1_egress_with_cidr_blocks1
}

module "ec2_eice" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"
  
  vpc_security_group_ids = [module.sg_ec2_eice.security_group_id]
  name                   = "${var.desc_tags.project}-${var.ec2_name}"
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = false
  subnet_id              = module.vpc_eice.intra_subnets[0]
  iam_instance_profile   = var.iam_instance_profile

  tags = var.desc_tags
}