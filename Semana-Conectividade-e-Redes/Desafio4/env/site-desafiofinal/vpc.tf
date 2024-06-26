module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = "${var.desc_tags.project}-vpc-desafio4"
  cidr = var.vpc_cidr_block

  azs              = var.subnet_availability_zones
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  tags = var.desc_tags

  default_vpc_enable_dns_support                              = true
  default_vpc_enable_dns_hostnames                            = true
  enable_nat_gateway                                          = true
  enable_vpn_gateway                                          = false
  single_nat_gateway                                          = true
  one_nat_gateway_per_az                                      = false
  public_dedicated_network_acl                                = false
  private_dedicated_network_acl                               = false
  map_public_ip_on_launch                                     = true
  database_subnet_enable_resource_name_dns_a_record_on_launch = true
  public_subnet_enable_resource_name_dns_a_record_on_launch   = true
  private_subnet_enable_resource_name_dns_a_record_on_launch  = true

  # Cloudwatch log group and IAM role will be created
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  flow_log_max_aggregation_interval         = 60
  flow_log_cloudwatch_log_group_name_prefix = "/${var.desc_tags.project}/"
  flow_log_cloudwatch_log_group_name_suffix = "vpc-flow-logs"
  flow_log_cloudwatch_log_group_class       = "STANDARD"
}

resource "aws_ecr_repository" "ecr" {
  name = lower("${var.ecr_repository}")
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.5"

  identifier = lower("${var.desc_tags.project}-db-pgsql")

  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14"
  major_engine_version = "14"
  instance_class       = var.rds_instance_class

  allocated_storage     = 20
  max_allocated_storage = 25

  db_name  = var.rds_db_name
  username = var.rds_username
  port     = 5432
  password = var.rds_password

  multi_az               = false
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.sg_rds.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = false

  skip_final_snapshot = true
  deletion_protection = false

  performance_insights_enabled          = false
  performance_insights_retention_period = 0
  create_monitoring_role                = false
  monitoring_interval                   = 0

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
  tags = var.desc_tags
}

#DNS Record
resource "aws_route53_record" "alb_dns_record" {
  zone_id = var.domain
  name    = var.alb_subdomain_dns_record
  type    = "CNAME"
  ttl     = 300
  records = [module.alb.dns_name]
}