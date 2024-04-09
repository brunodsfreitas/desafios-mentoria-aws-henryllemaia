module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.7"

  name = "${var.desc_tags.project}-vpc-ssm-public"
  cidr = var.vpc_cidr_block

  azs            = var.subnet_availability_zones
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  intra_subnets = var.intra_subnets

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
  intra_subnet_enable_resource_name_dns_a_record_on_launch   = true
  public_subnet_enable_resource_name_dns_a_record_on_launch  = true
  private_subnet_enable_resource_name_dns_a_record_on_launch = true
}

resource "aws_ecr_repository" "ecr" {
  name = lower("${var.ecr_repository}")
}