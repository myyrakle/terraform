terraform {
  required_providers {
    # 일종의 라이브러리 로드
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

locals {
  tags = {
    Environment = var.environment
    Application = var.server_name
  }

  resource_id = join("-", [var.server_name, var.environment])
}

// CloudWatch 로그 그룹
// 서버 로그 기록에 사용합니다.
resource "aws_cloudwatch_log_group" "log_group" {
  name              = local.resource_id
  retention_in_days = var.log_retention_in_days

  tags = local.tags
}

// ECR
// 서버 프로지버닝에 사용할 docker image를 관리합니다.
resource "aws_ecr_repository" "ecr" {
  name                 = local.resource_id
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags
}

// ECS 
// 서버를 배포할 ECS 클러스터입니다. 
resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.resource_id

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.tags
}

// ECS 작업 정의
resource "aws_ecs_task_definition" "task_definition" {
  family = local.resource_id

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.task_execution_role.arn

  memory = var.container_memory
  cpu    = var.container_cpu

  container_definitions = jsonencode([
    {
      name      = join("-", [var.server_name, var.environment])
      image     = join(":", [aws_ecr_repository.ecr.repository_url, var.docker_release_tag])
      cpu       = 0
      essential = true
      portMappings = [
        {
          containerPort = var.portforward_container_port
          hostPort      = var.portforward_host_port
        }
      ]
      entrypoint = var.entrypoint
    },
  ])

  tags = local.tags
}


// 로드밸런싱에 사용할 대상 그룹
resource "aws_lb_target_group" "target_group" {
  name             = local.resource_id
  port             = var.target_group_port
  protocol_version = var.target_group_protocol_version
  protocol         = var.target_group_protocol
  vpc_id           = var.vpc_id
  target_type      = "ip"
  health_check {
    enabled             = true
    path                = var.healthcheck_uri
    interval            = var.healthcheck_interval
    protocol            = var.target_group_protocol
    port                = var.target_group_port
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 30
  }

  tags = local.tags
}

// 오토스케일링 구성
resource "aws_appautoscaling_target" "auto_scailing" {
  max_capacity       = var.auto_scailing_max
  min_capacity       = 1
  resource_id        = "service/${local.resource_id}/${local.resource_id}"
  role_arn           = aws_iam_role.scalable_target_role.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

// CPU 스케일링 정책 구성입니다.
resource "aws_appautoscaling_policy" "scaling_policy_cpu" {
  name               = "${local.resource_id}-cpu-scailing"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.auto_scailing.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.cpu_scail_out_percent
    scale_in_cooldown  = 300
    scale_out_cooldown = 120
  }
}
