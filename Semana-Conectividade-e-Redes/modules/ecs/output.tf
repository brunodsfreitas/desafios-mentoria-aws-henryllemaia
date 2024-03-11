output "module_info" {
  description = "Informações Compartilhadas para outros módulos"
  value = {
    autoscaling_group_arn  = aws_autoscaling_group.this.arn
    autoscaling_group_name = aws_autoscaling_group.this.name
    vpc_id                 = aws_vpc.this.id
    alb_arn                = aws_alb.this.arn
    cluster_id             = aws_ecs_cluster.this.id
    alb_dns_name           = aws_alb.this.dns_name
  }
}