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
