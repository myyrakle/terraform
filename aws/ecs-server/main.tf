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

// 로드밸런서입니다.
resource "aws_lb" "loadbalancer" {
  name               = local.resource_id
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalancer_sg.id]

  dynamic "subnet_mapping" {
    for_each = var.subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = local.tags
}

// HTTP 리스너
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

// HTTPS 리스너
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

// ECS 서비스
resource "aws_ecs_service" "ecs_service" {
  name            = local.resource_id
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 0 // TODO: 최초 구성 시점에서는 codebuild가 돌지 않아 실행 불가. 최초 code build가 돌때까지 wait하는 기능을 고려할 필요 있음
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = local.resource_id
    container_port   = var.portforward_container_port
  }

  tags = local.tags
}
