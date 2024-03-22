###########################################################################
# Global Project Organization
###########################################################################

variable "region" {
  type        = string
  description = "Definição da Região"
  default     = "us-east-2"
}
variable "profile" {
  type        = string
  description = "Definição do AWS Profile"
  default     = "default"
}

variable "desc_tags" {
  type        = map(string)
  description = "Tags Globais do Projeto"
  default     = null
}

variable "domain" {
  type        = string
  description = "Zone ID do registro de DNS Route53"
  default     = null
}

###############
### VPC
###############
variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = null
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR Block"
  default     = null
}

variable "private_subnets" {
  type        = list(string)
  description = "Private Subnets CIDR Block"
  default     = null
}

variable "intra_subnets" {
  type        = list(string)
  description = "Intra Subnets CIDR Block"
  default     = null
}

variable "public_subnets" {
  type        = list(string)
  description = "Public Subnets CIDR Block"
  default     = null
}

variable "subnet_availability_zones" {
  type        = list(string)
  description = "Subnet availability zones"
  default     = null
}

variable "public_inbound_acl_rules" {
  type        = list(map(string))
  description = "public_inbound_acl_rules"
  default     = null
}

variable "public_outbound_acl_rules" {
  type        = list(map(string))
  description = "public_inbound_acl_rules"
  default     = null
}

variable "private_inbound_acl_rules" {
  type        = list(map(string))
  description = "private_inbound_acl_rules"
  default     = null
}

variable "private_outbound_acl_rules" {
  type        = list(map(string))
  description = "private_outbound_acl_rules"
  default     = null
}

###############
### EC2
###############
variable "ec2_name" {
  type        = string
  description = "EC2 name"
  default     = null
}
variable "instance_type" {
  type        = string
  description = "EC2 instance_type"
  default     = "t2.micro"
}
variable "key_name" {
  type        = string
  description = "EC2 key_name"
  default     = null
}
variable "iam_instance_profile" {
  type        = string
  description = "EC2 iam_instance_profile"
  default     = null
}
variable "user_data" {
  type        = string
  description = "EC2 user_data"
  default     = null
}

###############
### Security Groups
###############
variable "sg1_name" {
  type        = string
  description = "sg1_name"
  default     = null
}
variable "sg1_description" {
  type        = string
  description = "sg1_description"
  default     = null
}
variable "sg1_ingress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg1_ingress_with_cidr_blocks1"
  default     = null
}
variable "sg1_egress_with_cidr_blocks1" {
  type        = list(map(string))
  description = "sg1_egress_with_cidr_blocks1"
  default     = null
}