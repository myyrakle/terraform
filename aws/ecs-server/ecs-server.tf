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
}


resource "aws_cloudwatch_log_group" "log_group" {
  name              = join("-", [var.server_name], "log-group")
  retention_in_days = var.log_retention_in_days

  tags = {
    Environment = var.environment
    Application = var.server_name
  }
}

// CloudWatch 로그 그룹
// 서버 로그 기록에 사용합니다.
resource "aws_cloudwatch_log_group" "log_group" {
  name              = join("-", [var.server_name, var.var.environment])
  retention_in_days = var.log_retention_in_days

  tags = {
    Environment = var.environment
    Application = var.server_name
  }
}

// ECR
// 서버 프로지버닝에 사용할 docker image를 관리합니다.
resource "aws_ecr_repository" "ecr" {
  name                 = join("-", [var.server_name, var.environment])
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
  }
}
