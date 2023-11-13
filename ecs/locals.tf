locals {
    ecs_container_name = "${var.project_name}-ecs-container"
    ecs_default_ingress = [
      {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = "0.0.0.0/0"
      },
      {
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = "0.0.0.0/0"
      }
    ]
    ingress_on_application_port = [
      {
        from_port        = var.application_port
        to_port          = var.application_port
        protocol         = "tcp"
        cidr_blocks      = "0.0.0.0/0"
      }
    ]
    ingress_with_cidr_blocks = (
      var.application_port != 80 && var.application_port != 443
      ? concat(local.ecs_default_ingress, local.ingress_on_application_port)
      : local.ecs_default_ingress
    )
  // allow for easier checks on this optional variable, ex: local.hosted_zone_names > 0 ? do something : do something else
  hosted_zone_names = var.hosted_zone_names == null ? [] : var.hosted_zone_names
}
