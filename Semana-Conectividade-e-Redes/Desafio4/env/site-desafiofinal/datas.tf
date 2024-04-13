################################################################################
# Data
################################################################################

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}
data "external" "get_ip_range_eiec" {
  program = ["bash", "${path.module}/get_ip_range_aws_services.sh", "${var.region}", "EC2_INSTANCE_CONNECT"]
}