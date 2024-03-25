terraform {
  backend "local" {
    path = "terraform-backup-site.tfstate"
  }
}

module "vpc_backup" {
  source = "../../modules/vpc"

  name = var.desc_tags.project
  cidr = var.vpc_cidr_block

  azs            = var.subnet_availability_zones
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets

  public_inbound_acl_rules   = var.public_inbound_acl_rules
  public_outbound_acl_rules  = var.public_outbound_acl_rules
  public_acl_tags            = var.desc_tags
  private_inbound_acl_rules  = var.private_inbound_acl_rules
  private_outbound_acl_rules = var.private_outbound_acl_rules
  private_acl_tags           = var.desc_tags
  tags                       = var.desc_tags

  default_vpc_enable_dns_support                            = true
  default_vpc_enable_dns_hostnames                          = true
  enable_nat_gateway                                        = true
  enable_vpn_gateway                                        = false
  single_nat_gateway                                        = false
  one_nat_gateway_per_az                                    = true
  map_public_ip_on_launch                                   = false
  public_dedicated_network_acl                              = true
  private_dedicated_network_acl                             = true
  public_subnet_enable_resource_name_dns_a_record_on_launch = true
}

module "sg_ec2_backup" {
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg1_name}"
  description = var.sg1_description
  vpc_id      = module.vpc_backup.vpc_id

  ingress_cidr_blocks     = [module.vpc_backup.vpc_cidr_block]
  egress_with_cidr_blocks = var.sg1_egress_with_cidr_blocks1
}

module "ec2_instance_backup" {
  source                 = "../../modules/ec2"
  vpc_security_group_ids = [module.sg_ec2_backup.security_group_id]
  name                   = "${var.desc_tags.project}-${var.ec2_name}"
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = false
  subnet_id              = module.vpc_backup.private_subnets[0]
  iam_instance_profile   = var.iam_instance_profile
  user_data              = base64encode(var.user_data)

  tags = var.desc_tags
}

resource "aws_kms_key" "kms_ebs" {
  description = var.kms_key_description
  tags        = var.desc_tags
}

resource "aws_volume_attachment" "backup_data_disk" {
  device_name = "/dev/sdf"
  instance_id = module.ec2_instance_backup.id
  volume_id   = aws_ebs_volume.ebs_backup_data.id
}

resource "aws_ebs_volume" "ebs_backup_data" {
  availability_zone = var.ebs_availability_zone_name
  size              = var.ebs_size
  encrypted         = true
  final_snapshot    = false
  type              = "gp3"
  kms_key_id        = aws_kms_key.kms_ebs.arn
  throughput        = 125
  tags              = merge({ "Name" = "${var.desc_tags.project}-ebs-${var.ebs_name}" }, var.desc_tags)
}