terraform {
  backend "local" {
    path = "terraform-prod.tfstate"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name = var.desc_tags.project
  cidr = var.vpc_cidr_block

  azs             = var.subnet_availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  intra_subnets   = var.intra_subnets

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
  one_nat_gateway_per_az                                     = true
  public_dedicated_network_acl                               = true
  private_dedicated_network_acl                              = true
  map_public_ip_on_launch                                    = true
  intra_subnet_enable_resource_name_dns_a_record_on_launch   = true
  public_subnet_enable_resource_name_dns_a_record_on_launch  = true
  private_subnet_enable_resource_name_dns_a_record_on_launch = true
}

module "sg_ec2_bastion_host" {
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg1_name}"
  description = var.sg1_description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg1_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg1_egress_with_cidr_blocks1
}

module "ec2_bastion_host" {
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

module "sg_ec2_tosios" {
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg2_name}"
  description = var.sg2_description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg2_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg2_egress_with_cidr_blocks1
}

module "ec2_tosios" {
  source                 = "../../modules/ec2"
  vpc_security_group_ids = [module.sg_ec2_tosios.security_group_id]
  name                   = "${var.desc_tags.project}-${var.ec2_2_name}"
  instance_type          = var.ec2_2_instance_type
  key_name               = var.ec2_2_key_name
  ami                    = var.ec2_2_ami
  monitoring             = false
  subnet_id              = module.vpc.intra_subnets[1]
  iam_instance_profile   = var.ec2_2_iam_instance_profile
  user_data              = base64encode(var.ec2_2_user_data)

  tags = var.desc_tags
}

module "sg_ec2_qr" {
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg3_name}"
  description = var.sg3_description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg3_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg3_egress_with_cidr_blocks1
}

module "ec2_qr" {
  source                 = "../../modules/ec2"
  vpc_security_group_ids = [module.sg_ec2_qr.security_group_id]
  name                   = "${var.desc_tags.project}-${var.ec2_3_name}"
  instance_type          = var.ec2_3_instance_type
  key_name               = var.ec2_3_key_name
  ami                    = var.ec2_3_ami
  monitoring             = false
  subnet_id              = module.vpc.private_subnets[1]
  iam_instance_profile   = var.ec2_3_iam_instance_profile
  user_data              = base64encode(var.ec2_3_user_data)

  tags = var.desc_tags
}

module "sg_ec2_prod" {
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg4_name}"
  description = var.sg4_description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg4_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg4_egress_with_cidr_blocks1
}

module "ec2_prod" {
  source                 = "../../modules/ec2"
  vpc_security_group_ids = [module.sg_ec2_prod.security_group_id]
  name                   = "${var.desc_tags.project}-${var.ec2_4_name}"
  instance_type          = var.ec2_4_instance_type
  key_name               = var.ec2_4_key_name
  ami                    = var.ec2_4_ami
  monitoring             = false
  subnet_id              = module.vpc.private_subnets[0]
  iam_instance_profile   = var.ec2_4_iam_instance_profile
  user_data              = base64encode(var.ec2_4_user_data)

  tags = var.desc_tags
}

resource "aws_kms_key" "kms_ebs" {
  description = var.kms_key_description
  tags        = var.desc_tags
}

resource "aws_volume_attachment" "backup_data_disk" {
  device_name = "/dev/sdf"
  instance_id = module.ec2_prod.id
  volume_id   = aws_ebs_volume.ebs_prod_data.id
}

resource "aws_ebs_volume" "ebs_prod_data" {
  availability_zone = var.ebs_availability_zone_name
  size              = var.ebs_size
  encrypted         = true
  final_snapshot    = false
  type              = "gp3"
  kms_key_id        = aws_kms_key.kms_ebs.arn
  throughput        = 125
  tags              = merge({ "Name" = "${var.desc_tags.project}-ebs-${var.ebs_name}" }, var.desc_tags)
}

### VPC ENDPOINTS
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [module.sg_endpoints.security_group_id]
  subnet_ids         = [module.vpc.public_subnets[0]] #apenas na az1

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [module.sg_endpoints.security_group_id]
  subnet_ids         = [module.vpc.public_subnets[0]] #apenas na az1

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [module.sg_endpoints.security_group_id]
  subnet_ids         = [module.vpc.public_subnets[0]] #apenas na az1

  private_dns_enabled = true
}

resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id          = module.vpc.public_subnets[1] #apenas na az2
  security_group_ids = [module.sg_endpoints.security_group_id]
}

module "sg_endpoints" {
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg5_name}"
  description = var.sg5_description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg5_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg5_egress_with_cidr_blocks1
}

module "sg_alb" {
  source = "../../modules/sg"

  name        = "${var.desc_tags.project}-sg-${var.sg6_name}"
  description = var.sg6_description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = var.sg6_ingress_with_cidr_blocks1
  egress_with_cidr_blocks  = var.sg6_egress_with_cidr_blocks1
}

# ALB
resource "aws_lb" "this" {
  name                       = "alb"
  internal                   = false
  load_balancer_type         = "application"
  ip_address_type            = "ipv4"
  enable_deletion_protection = false
  security_groups            = [module.sg_alb.security_group_id]
  subnets                    = module.vpc.public_subnets
  tags                       = var.desc_tags
}

# Target Group
resource "aws_lb_target_group" "qr" {
  name                 = "tg-qr"
  port                 = 3000
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 60
  tags                 = var.desc_tags
}
resource "aws_lb_target_group_attachment" "qr" {
  target_group_arn = aws_lb_target_group.qr.arn
  target_id        = module.ec2_qr.id
}

# Target Group
resource "aws_lb_target_group" "tosios" {
  name                 = "tg-tosios"
  port                 = 3001
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 60
  tags                 = var.desc_tags
}
resource "aws_lb_target_group_attachment" "tosios" {
  target_group_arn = aws_lb_target_group.tosios.arn
  target_id        = module.ec2_tosios.id
}

# Target Group
resource "aws_lb_target_group" "bia" {
  name                 = "tg-bia"
  port                 = 3001
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 60
  tags                 = var.desc_tags
}
resource "aws_lb_target_group_attachment" "bia" {
  target_group_arn = aws_lb_target_group.bia.arn
  target_id        = module.ec2_prod.id
}

# Listener HTTP 80
resource "aws_lb_listener" "listener80" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  tags              = var.desc_tags
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bia.arn
  }
}

# Rule Listener
resource "aws_lb_listener_rule" "qr" {
  listener_arn = aws_lb_listener.listener80.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.qr.arn
  }

  condition {
    host_header {
      values = ["qr.brunofreitas.tec.br"]
    }
  }
}

# Rule Listener
resource "aws_lb_listener_rule" "tosios" {
  listener_arn = aws_lb_listener.listener80.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tosios.arn
  }

  condition {
    host_header {
      values = ["tosios.brunofreitas.tec.br"]
    }
  }
}

# Rule Listener
resource "aws_lb_listener_rule" "bia" {
  listener_arn = aws_lb_listener.listener80.arn
  priority     = 102

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bia.arn
  }

  condition {
    host_header {
      values = ["bia.brunofreitas.tec.br"]
    }
  }
}

#DNS Record
resource "aws_route53_record" "qr" {
  zone_id = var.domain
  name    = "qr"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.this.dns_name]
}

#DNS Record
resource "aws_route53_record" "tosios" {
  zone_id = var.domain
  name    = "tosios"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.this.dns_name]
}

#DNS Record
resource "aws_route53_record" "bia" {
  zone_id = var.domain
  name    = "bia"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.this.dns_name]
}