#!/bin/bash
git submodule add -f https://github.com/terraform-aws-modules/terraform-aws-ecr.git ./modules/ecr/
git submodule add -f https://github.com/terraform-aws-modules/terraform-aws-vpc.git ./modules/vpc/
git submodule add -f https://github.com/terraform-aws-modules/terraform-aws-route53.git ./modules/route53/
git submodule add -f https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git ./modules/ec2/
git submodule add -f https://github.com/terraform-aws-modules/terraform-aws-security-group.git ./modules/sg/
git submodule add -f https://github.com/terraform-aws-modules/terraform-aws-autoscaling.git ./modules/asg/
git submodule add -f https://github.com/terraform-aws-modules/terraform-aws-efs.git ./modules/efs/
git submodule add -f https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git ./modules/s3/
git submodule add -f https://github.com/terraform-aws-modules/terraform-aws-alb.git ./modules/alb/
git submodule add -f https://github.com/terraform-aws-modules/terraform-aws-ecs.git ./modules/ecs/