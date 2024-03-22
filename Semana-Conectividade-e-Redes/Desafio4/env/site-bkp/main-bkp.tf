terraform {
  backend "local" {
    path = "terraform-backup-site.tfstate"
  }
}

module "vpc_backup" { #https://github.com/terraform-aws-modules/terraform-aws-vpc
  source = "../../modules/vpc"

  name = "${var.desc_tags.project}-vpc-backup"
  cidr = var.vpc_cidr_block

  azs             = var.subnet_availability_zones
  public_subnets  = var.public_subnets

  public_inbound_acl_rules   = var.public_inbound_acl_rules
  public_outbound_acl_rules  = var.public_outbound_acl_rules
  public_acl_tags            = var.desc_tags
  private_inbound_acl_rules  = var.private_inbound_acl_rules
  private_outbound_acl_rules = var.private_outbound_acl_rules
  private_acl_tags           = var.desc_tags
  tags                       = var.desc_tags

  default_vpc_enable_dns_support                             = true
  default_vpc_enable_dns_hostnames                           = true
  enable_nat_gateway                                         = false
  enable_vpn_gateway                                         = false
  single_nat_gateway                                         = false
  one_nat_gateway_per_az                                     = false
  public_dedicated_network_acl                               = true
  private_dedicated_network_acl                              = true
  public_subnet_enable_resource_name_dns_a_record_on_launch  = true
}

module "sg_ec2_backup" { #https://github.com/terraform-aws-modules/terraform-aws-security-group
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg1_name}"
  description = var.sg1_description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg1_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg1_egress_with_cidr_blocks1
}

module "ec2_instance" { #https://github.com/terraform-aws-modules/terraform-aws-ec2-instance
  source                 = "../../modules/ec2"
  vpc_security_group_ids = [module.sg_ec2_bastion_host.security_group_id]
  name                   = "${var.desc_tags.project}-${var.ec2_name}"
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = false
  subnet_id              = module.vpc.public_subnets[0]
  iam_instance_profile   = var.iam_instance_profile
  user_data              = base64encode(var.user_data)

  tags = var.desc_tags
}