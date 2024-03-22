#!/bin/bash
rm -fR modules/vpc
git clone --single-branch https://github.com/terraform-aws-modules/terraform-aws-vpc.git modules/vpc/
rm -fR modules/asg
git clone --single-branch https://github.com/terraform-aws-modules/terraform-aws-autoscaling.git modules/asg/
rm -fR modules/sg
git clone --single-branch https://github.com/terraform-aws-modules/terraform-aws-security-group.git modules/sg/
rm -fR modules/efs
git clone --single-branch https://github.com/terraform-aws-modules/terraform-aws-efs.git modules/efs/
rm -fR modules/ecr
git clone --single-branch https://github.com/terraform-aws-modules/terraform-aws-ecr.git modules/ecr/
rm -fR modules/s3
git clone --single-branch https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git modules/s3/
rm -fR modules/alb
git clone --single-branch https://github.com/terraform-aws-modules/terraform-aws-alb.git modules/alb/
rm -fR modules/route53
git clone --single-branch https://github.com/terraform-aws-modules/terraform-aws-route53.git modules/route53/
rm -fR modules/ec2
git clone --single-branch https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git modules/ec2/
rm -fR modules/ecs
git clone --single-branch https://github.com/terraform-aws-modules/terraform-aws-ecs.git modules/ecs