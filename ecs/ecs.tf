resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "${var.project_name}-api-logs"
  retention_in_days = 180

  tags = {
    name        = "${var.project_name}-api-logs"
    ProjectName = var.project_name
  }
}

resource "aws_ecs_task_definition" "task_def" {
  cpu                      = var.ecs_task_def_cpu
  memory                   = var.ecs_task_def_memory
  family                   = "${var.project_name}-task-def"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs-task-role.arn
  task_role_arn            = aws_iam_role.ecs-task-role.arn

  container_definitions = jsonencode([
    {
      name  = local.ecs_container_name
      image = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.project_name}:latest"

      portMappings = [
        {
          containerPort = var.application_port
          hostPort      = var.application_port
          protocol      = "tcp"
        }
      ]

      environment : var.env_vars

      logConfiguration = {
        logDriver : "awslogs"
        options : {
          awslogs-group : "${var.project_name}-api-logs"
          awslogs-region : "${var.region}"
          awslogs-stream-prefix : "${var.project_name}-api-logs"
        }
      }
    }
  ])

  tags = {
    ProjectName = var.project_name
  }
}

data "aws_ecs_task_definition" "task_def" {
  task_definition = aws_ecs_task_definition.task_def.family
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-cluster"

  tags = {
    name        = "${var.project_name}-cluster"
    ProjectName = var.project_name
  }
}

resource "aws_ecs_service" "ecs" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = "${aws_ecs_task_definition.task_def.family}:${max("${aws_ecs_task_definition.task_def.revision}", "${data.aws_ecs_task_definition.task_def.revision}")}"
  desired_count   = var.ecs_desired_task_count
  launch_type     = "FARGATE"
  depends_on      = [aws_lb_listener.lb_listener]

  network_configuration {
    security_groups  = [module.fargate_security_group.security_group_id]
    subnets          = var.vpc_public_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = local.ecs_container_name
    container_port   = var.application_port
  }

  tags = {
    name        = "${var.project_name}-service"
    ProjectName = var.project_name
  }
}
