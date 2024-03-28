terraform {
  backend "local" {
    path = "terraform-prod.tfstate"
  }
}

module "vpc_eice" {
  source = "../../modules/vpc"

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
  intra_subnet_enable_resource_name_dns_a_record_on_launch   = false
  public_subnet_enable_resource_name_dns_a_record_on_launch  = true
  private_subnet_enable_resource_name_dns_a_record_on_launch = true
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

module "vpc_ssm_public" {
  source = "../../modules/vpc"

  name = "${var.desc_tags.project}-vpc-ssm-public"
  cidr = var.vpc3_cidr_block

  azs            = var.subnet_availability_zones
  public_subnets = var.public_subnets

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

module "vpc_ssm_endpoints" {
  source = "../../modules/vpc"

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

module "sg_instance_connect_endpoint" {
  source = "../../modules/sg"

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

module "sg_endpoints" {
  source = "../../modules/sg"

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


module "sg_ec2_eice" {
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg1_name}"
  description = var.sg1_description
  vpc_id      = module.vpc_eice.vpc_id

  ingress_cidr_blocks      = [module.vpc_eice.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg1_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg1_egress_with_cidr_blocks1
}

module "ec2_eice" {
  source                 = "../../modules/ec2"
  vpc_security_group_ids = [module.sg_ec2_eice.security_group_id]
  name                   = "${var.desc_tags.project}-${var.ec2_name}"
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = false
  subnet_id              = module.vpc_eice.intra_subnets[0]
  iam_instance_profile   = var.iam_instance_profile

  tags = var.desc_tags
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

module "sg_ec2_ssm_public" {
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg3_name}"
  description = var.sg3_description
  vpc_id      = module.vpc_ssm_public.vpc_id

  ingress_cidr_blocks      = [module.vpc_ssm_public.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg3_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg3_egress_with_cidr_blocks1
}

module "ec2_ssm_public" {
  source                 = "../../modules/ec2"
  vpc_security_group_ids = [module.sg_ec2_ssm_public.security_group_id]
  name                   = "${var.desc_tags.project}-${var.ec2_3_name}"
  instance_type          = var.ec2_3_instance_type
  key_name               = var.ec2_3_key_name
  monitoring             = false
  subnet_id              = module.vpc_ssm_public.public_subnets[0]
  iam_instance_profile   = var.ec2_3_iam_instance_profile

  tags = var.desc_tags
}

module "sg_ec2_ssm_endpoints" {
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg6_name}"
  description = var.sg6_description
  vpc_id      = module.vpc_ssm_endpoints.vpc_id

  ingress_cidr_blocks      = [module.vpc_ssm_endpoints.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg6_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg6_egress_with_cidr_blocks1
}

module "ec2_ssm_endpoints" {
  source                 = "../../modules/ec2"
  vpc_security_group_ids = [module.sg_ec2_ssm_endpoints.security_group_id]
  name                   = "${var.desc_tags.project}-${var.ec2_4_name}"
  instance_type          = var.ec2_4_instance_type
  key_name               = var.ec2_4_key_name
  monitoring             = false
  subnet_id              = module.vpc_ssm_endpoints.private_subnets[0]
  iam_instance_profile   = var.ec2_4_iam_instance_profile

  tags = var.desc_tags
}
