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
  execution_role_arn       = var.execution_role_arn != "" ? var.execution_role_arn : aws_iam_role.ecs-task-execution-role.arn
  task_role_arn            = var.task_role_arn != "" ? var.task_role_arn : aws_iam_role.ecs-task-role.arn

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

resource "aws_ecs_task_definition" "additional_task_def" {
  count = var.additional_task_def != null ? 1 : 0

  cpu                      = var.additional_task_def.ecs_task_def_cpu
  memory                   = var.additional_task_def.ecs_task_def_memory
  family                   = "${var.additional_task_def.name}-task-def"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.additional_task_def.execution_role_arn != "" ? var.additional_task_def.execution_role_arn : aws_iam_role.ecs-task-execution-role.arn
  task_role_arn            = var.additional_task_def.task_role_arn != "" ? var.additional_task_def.task_role_arn : aws_iam_role.ecs-task-role.arn

  container_definitions = jsonencode([
    {  
      name  = var.additional_task_def.ecs_container_name
      image = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.project_name}:${var.additional_task_def.tag_name}"

      portMappings = [
        {
          containerPort = var.additional_task_def.container_port
          hostPort      = var.additional_task_def.host_port
          protocol      = "tcp"
        }
      ]

      environment : var.additional_task_def.env_vars

      logConfiguration = {
        logDriver : "awslogs"
        options : {
          awslogs-group : "${var.additional_task_def.name}-api-logs"
          awslogs-region : "${var.region}"
          awslogs-stream-prefix : "${var.additional_task_def.name}-api-logs"
        }
      }
    }
  ])

  tags = {
    ProjectName = var.additional_task_def.name
  }
}
# Log Group required for Additonal task def added conditionally
resource "aws_cloudwatch_log_group" "additional_task_log_group" {
  count = var.additional_task_def != null ? 1 : 0

  name              = "${var.additional_task_def.name}-api-logs"
  retention_in_days = 180

  tags = {
    name        = "${var.additional_task_def.name}-api-logs"
    ProjectName = var.project_name
  }
}

# Parameters required for ecs task
resource "aws_ssm_parameter" "additional_task_def_arn" {
  count = var.additional_task_def != null ? 1 : 0
  
  name  = "/${var.project_name}/additional_taskdef_arn"
  type  = "String"
  value = aws_ecs_task_definition.additional_task_def[0].arn_without_revision
}

resource "aws_ssm_parameter" "ecs_cluster_id" {
  name  = "/${var.project_name}/ecs_cluster_id"
  type  = "String"
  value = aws_ecs_cluster.ecs_cluster.id
}

resource "aws_ssm_parameter" "task_security_group_id" {
  name  = "/${var.project_name}/task_security_group_id"
  type  = "String"
  value = module.fargate_security_group.security_group_id
}