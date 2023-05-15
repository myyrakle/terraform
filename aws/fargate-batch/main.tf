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
      name      = local.resource_id
      image     = local.release_image
      cpu       = 0
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
  ])

  tags = local.tags
}
