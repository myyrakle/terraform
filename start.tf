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

resource "ec2" "server" {
  tags = {
    Name = var.server_name
  }

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
