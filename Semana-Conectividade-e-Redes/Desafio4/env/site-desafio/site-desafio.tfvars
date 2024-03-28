#GLOBAL 
region  = "us-east-2"
profile = "default"
domain  = "Z0100196EO0CLYZ2G2UN" #change
###########################################################################
# Global Project Organization
###########################################################################
desc_tags = {
  project      = "SemanaConectividadeAWS"
  orgunit      = "Desafio4"
  businessunit = "Matriz"
  costcenter   = "estudos"
  appid        = "01.01"
  appname      = "VPC_Peering"
  desc         = "Conectividade entre regiões"
  environment  = "lab-desafio-conectividade-4"
  createdby    = "BrunoFreitas"
  terraform    = "true"
  #createdon                  = timeadd(timestamp(), "-3h")
}
###########################################################################
# VPC
###########################################################################
vpc_cidr_block  = "10.15.0.0/16"
vpc2_cidr_block = "10.20.0.0/16"
vpc3_cidr_block = "10.25.0.0/16"
vpc4_cidr_block = "10.30.0.0/16"
###########################################################################
# VPC - Subnets
###########################################################################
vpc2_private_subnets      = ["10.20.2.0/24"]
vpc4_private_subnets      = ["10.30.50.0/24"]
public_subnets            = ["10.25.3.0/24"]
vpc2_public_subnets       = ["10.20.200.0/24"]
vpc4_public_subnets       = ["10.30.110.0/24"]
intra_subnets             = ["10.15.1.0/24"]
subnet_availability_zones = ["us-east-2a"]
public_inbound_acl_rules = [
  {
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }
]
public_outbound_acl_rules = [
  {
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }
]
private_inbound_acl_rules = [
  {
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }
]
private_outbound_acl_rules = [
  {
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }
]
###########################################################################
#### Security Group Instance Connect Endpoint
###########################################################################
sg4_name        = "instance connect endpoints"
sg4_description = "allow vpc in and outbound"
sg4_ingress_with_cidr_blocks1 = [
  {}
]
sg4_egress_with_cidr_blocks1 = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "ssh subnet intra(ipv4)"
    cidr_blocks = "10.15.1.0/24"
  }
]
###########################################################################
# Security Group eice
###########################################################################
sg1_name        = "ec2-eice"
sg1_description = "allow access ssh ec2 bastion host"
sg1_ingress_with_cidr_blocks1 = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH from world (ipv4)"
    cidr_blocks = "0.0.0.0/0"
  }
]
sg1_egress_with_cidr_blocks1 = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all out (ipv4)"
    cidr_blocks = "0.0.0.0/0"
  }
]
###########################################################################
# Security Group ssm
###########################################################################
sg2_name        = "ec2-ssm"
sg2_description = "allow access ssh ec2 bastion host"
sg2_ingress_with_cidr_blocks1 = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH from world (ipv4)"
    cidr_blocks = "0.0.0.0/0"
  }
]
sg2_egress_with_cidr_blocks1 = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all out (ipv4)"
    cidr_blocks = "0.0.0.0/0"
  }
]
###########################################################################
# Security Group ssm public
###########################################################################
sg3_name        = "ec2-ssm-public"
sg3_description = "allow access ssh ec2 bastion host"
sg3_ingress_with_cidr_blocks1 = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH from world (ipv4)"
    cidr_blocks = "0.0.0.0/0"
  }
]
sg3_egress_with_cidr_blocks1 = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all out (ipv4)"
    cidr_blocks = "0.0.0.0/0"
  }
]
###########################################################################
# Security Group ec2 ssm endpoints
###########################################################################
sg6_name        = "ec2-ssm-endpoints"
sg6_description = "allow access ssh ec2 bastion host"
sg6_ingress_with_cidr_blocks1 = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH from world (ipv4)"
    cidr_blocks = "0.0.0.0/0"
  }
]
sg6_egress_with_cidr_blocks1 = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all out (ipv4)"
    cidr_blocks = "0.0.0.0/0"
  }
]
###########################################################################
#### Security Group Endpoints
###########################################################################
sg5_name        = "endpoints"
sg5_description = "allow vpc in and outbound"
sg5_ingress_with_cidr_blocks1 = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all (ipv4)"
    cidr_blocks = "0.0.0.0/0"
  }
]
sg5_egress_with_cidr_blocks1 = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all out (ipv4)"
    cidr_blocks = "10.30.0.0/16"
  }
]
###########################################################################
# EC2
###########################################################################
###########################################################################
#### EC2 - EICE
###########################################################################
ec2_name             = "teste-instance-connect"
instance_type        = "t3.micro"
key_name             = "laboratorio-aws-2024-keys"
iam_instance_profile = "role-acesso-ssm"
user_data            = ""
###########################################################################
#### EC2 - SSM
###########################################################################
ec2_2_name                 = "teste-SSM-private"
ec2_2_instance_type        = "t3.micro"
ec2_2_key_name             = "laboratorio-aws-2024-keys"
ec2_2_iam_instance_profile = "role-acesso-ssm"
###########################################################################
#### EC2 - SSM PUBLIC
###########################################################################
ec2_3_name                 = "teste-SSM-Public"
ec2_3_instance_type        = "t3.micro"
ec2_3_key_name             = "laboratorio-aws-2024-keys"
ec2_3_iam_instance_profile = "role-acesso-ssm"
###########################################################################
#### EC2 - SSM ENDPOINTS
###########################################################################
ec2_4_name                 = "teste-SSM-Endpoints"
ec2_4_instance_type        = "t3.micro"
ec2_4_key_name             = "laboratorio-aws-2024-keys"
ec2_4_iam_instance_profile = "role-acesso-ssm"