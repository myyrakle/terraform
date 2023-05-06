locals {
  container_definitions = [
    {
      name      = local.resource_id
      image     = local.release_image
      essential = true
      portMappings = [
        {
          containerPort : var.portforward_container_port
          hostPort = var.portforward_host_port
        }
      ]
      entrypoint = var.docker_entrypoint
      logConfiguration = {
        "LogDriver" : "awslogs",
        "Options" : {
          "awslogs-group" : aws_cloudwatch_log_group.log_group.name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : local.resource_id
        }
      }
    },
  ]

  taskdef = jsonencode({
    family = local.resource_id

    requiresCompatibilities = [
      "FARGATE"
    ],

    networkMode = "awsvpc",

    executionRoleArn = aws_iam_role.task_execution_role.arn,

    memory = "${var.container_memory}"
    cpu    = "${var.container_cpu}"

    containerDefinitions = local.container_definitions,

    tags = local.tags
  })
}
