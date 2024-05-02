################################################################################
# Instance Profile
################################################################################
resource "aws_iam_instance_profile" "bia_service_instance_profile" {
  name = "bia_service_instance_profile"
  role = aws_iam_role.ecs_service_role.name
}
################################################################################
# Roles
################################################################################
### Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
### ECS Service Role
resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs-service-role"
  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ecs.amazonaws.com",
                    "ec2.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}
################################################################################
# Policies
################################################################################
locals {
  policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
    "${aws_iam_policy.instance_connect.arn}"
  ]
}
# Instance Connect Policy
resource "aws_iam_policy" "instance_connect" {
  name        = "policy-instance-connect-bia"
  description = "Policy for allowing EC2 instance connect and describe instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2-instance-connect:SendSSHPublicKey",
          "ec2-instance-connect:OpenTunnel"
        ]
        Resource = "arn:aws:ec2:${var.region}:*:*"
      },
      {
        Effect   = "Allow"
        Action   = "ec2:DescribeInstances"
        Resource = "*"
      }
    ]
  })
}
### Service Policies Attachment
resource "aws_iam_role_policy_attachment" "ecs_service_policy_attachments" {
  for_each   = { for idx, policy in local.policies : idx => policy }
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = each.value
}

### Task Policy Attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


#resource "aws_iam_role_policy_attachment" "instance_connect_policy_attachment" {
#  role       = aws_iam_role.ecs_service_role.name
#  policy_arn = aws_iam_policy.instance_connect.arn
#}