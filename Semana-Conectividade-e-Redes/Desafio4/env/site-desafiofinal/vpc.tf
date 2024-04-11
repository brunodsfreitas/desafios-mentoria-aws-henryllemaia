module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.7"

  name = "${var.desc_tags.project}-vpc-desafio4"
  cidr = var.vpc_cidr_block

  azs             = var.subnet_availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  intra_subnets   = var.intra_subnets

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

################################################################################
# Endpoints
################################################################################

resource "aws_vpc_endpoint" "ecr_endpoint" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  security_group_ids  = [module.sg_ecr_endpoint.security_group_id]
  subnet_ids          = module.vpc.private_subnets
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
}

resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id          = module.vpc.private_subnets[0]
  security_group_ids = [module.sg_eice.security_group_id]
}

data "external" "get_ip_range_eiec" {
  program = ["bash", "${path.module}/get_ip_range_aws_services.sh", "${var.region}", "EC2_INSTANCE_CONNECT"]
}

resource "aws_security_group_rule" "eiec_sg_rules" {
  count             = length(keys(data.external.get_ip_range_eiec.result))
  security_group_id = module.autoscaling_sg.security_group_id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [element(keys(data.external.get_ip_range_eiec.result), count.index)]
}


#deletar
#resource "aws_route_table_association" "eice_rt_association" {
#  count          = length(module.vpc.private_subnets)
#  subnet_id      = module.vpc.private_subnets[count.index]
#  route_table_id = aws_route_table.rt_endpoints.id
#}

#deletar
#resource "aws_route_table" "rt_endpoints" {
#  vpc_id = module.vpc.vpc_id
#}

#resource "aws_route" "eice_route" {
#  count                  = length(module.vpc.private_route_table_ids) * length(data.external.get_ip_range_eiec.result)
#  route_table_id         = module.vpc.private_route_table_ids[count.index / length(data.external.get_ip_range_eiec.result)]
#  destination_cidr_block = keys(data.external.get_ip_range_eiec.result)[count.index % length(data.external.get_ip_range_eiec.result)]
#  vpc_endpoint_id        = aws_vpc_endpoint.ecr_endpoint.id
#}

module "sg_eice" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

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
  version = "5.1.2"

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
