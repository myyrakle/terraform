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

resource "aws_instance" "app_server" {
  ami           = "ami-0e9bfdb247cc8de84" # ami 이미지
  instance_type = "t2.nano"               # 인스턴스 타입

  tags = {
    Name = "TestInstance" # 인스턴스명
  }
}
