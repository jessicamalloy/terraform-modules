output "ecs_service" {
    value = aws_ecs_service.ecs.name
}

output "ecs_cluster" {
    value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_container" {
    value = local.ecs_container_name
}

output "service_url" {
    value = "https://${aws_route53_record.r53_record.name}/"
}

output "lb_arn_suffix" {
    value = aws_lb.lb.arn_suffix
}

output "lb_tg_arn_suffix" {
    value = aws_lb_target_group.lb_target_group.arn_suffix
}
