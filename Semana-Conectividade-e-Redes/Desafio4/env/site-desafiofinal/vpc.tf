module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.7"

  name = "${var.desc_tags.project}-vpc-desafio4"
  cidr = var.vpc_cidr_block

  azs             = var.subnet_availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  #intra_subnets   = var.intra_subnets
  database_subnets = var.database_subnets

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

  # Cloudwatch log group and IAM role will be created
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  flow_log_max_aggregation_interval         = 60
  flow_log_cloudwatch_log_group_name_prefix = "/${var.desc_tags.project}/"
  flow_log_cloudwatch_log_group_name_suffix = "vpc-flow-logs"
  #flow_log_cloudwatch_log_group_class       = "INFREQUENT_ACCESS"
  flow_log_cloudwatch_log_group_class       = "STANDARD"
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
  subnet_ids          = [module.vpc.public_subnets[0]]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_api_endpoint" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  security_group_ids  = [module.sg_ecr_endpoint.security_group_id]
  subnet_ids          = [module.vpc.public_subnets[0]]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs_agent_endpoint" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [module.sg_ecr_endpoint.security_group_id]
  subnet_ids          = [module.vpc.public_subnets[0]]


}

resource "aws_vpc_endpoint" "ecs_telemetry_endpoint" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [module.sg_ecr_endpoint.security_group_id]
  subnet_ids          = [module.vpc.public_subnets[0]]

}

resource "aws_vpc_endpoint" "ecs_endpoint" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [module.sg_ecr_endpoint.security_group_id]
  subnet_ids          = [module.vpc.public_subnets[0]]

}

resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id          = module.vpc.private_subnets[0]
  security_group_ids = [module.sg_eice.security_group_id]
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.5"

  identifier = lower("${var.desc_tags.project}-db-mysql")

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 25

  db_name  = "bia"
  username = "admin"
  port     = 3306

  multi_az               = false
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.sg_rds.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]
  create_cloudwatch_log_group     = false

  skip_final_snapshot = true
  deletion_protection = false

  performance_insights_enabled          = false
  performance_insights_retention_period = 0
  create_monitoring_role                = false
  monitoring_interval                   = 0

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
  tags = var.desc_tags
}
/*
resource "aws_route" "ecs_agent_route" {
  count = module.vpc.private_route_table_ids
  route_table_id            = module.vpc.private_route_table_ids[count.index]
  vpc_endpoint_id           = aws_vpc_endpoint.ecs_agent_endpoint.id
  destination_cidr_block = "local"
}

resource "aws_route" "ecr_dkr_route" {
  count = module.vpc.private_route_table_ids
  route_table_id            = module.vpc.private_route_table_ids[count.index]
  vpc_endpoint_id           = aws_vpc_endpoint.ecr_endpoint.id
  destination_cidr_block = "local"
}

resource "aws_route" "ecs_telemetry_route" {
  count = module.vpc.private_route_table_ids
  route_table_id            = module.vpc.private_route_table_ids[count.index]
  vpc_endpoint_id           = aws_vpc_endpoint.ecs_telemetry_endpoint.id
  destination_cidr_block = "local"
}*/