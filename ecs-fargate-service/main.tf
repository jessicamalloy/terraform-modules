data "aws_region" "current" {}

resource "aws_ecs_service" "ecs_service" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.ecs_service.arn
  desired_count   = var.desired_count

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    # task_definition is updated via GitHub Actions so don't manage here after creation
    ignore_changes = [desired_count, task_definition]
  }


  # Networking
  network_configuration {
    security_groups  = var.security_groups
    subnets          = var.subnets
    assign_public_ip = var.assign_public_ip
  }

  launch_type = "FARGATE"

  dynamic "service_registries" {
    for_each = var.service_registries
    content {
      registry_arn = service_registries.value.registry_arn
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = var.name
      container_port   = load_balancer.value.container_port
    }
  }
}

resource "aws_ecs_task_definition" "ecs_service" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.name}",
    "image": "${var.image}",
    "essential": ${var.essential},
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.logs.name}",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-stream-prefix": "${var.cloudwatch_stream_prefix}"
      }
    },
    "environment":  ${jsonencode(var.environment_vars)},
    "portMappings": ${jsonencode(var.port_mappings)},
    "secrets": ${jsonencode(var.secrets)}
  }
]
DEFINITION
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloud_watch_retention
}
