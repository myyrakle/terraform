// 로드밸런서 보안그룹
resource "aws_security_group" "loadbalancer_sg" {
  name        = "${local.resource_id}-lb-sg"
  description = ""
  vpc_id      = var.vpc_id

  ingress {
    description = "allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = local.tags
}

// ECS Service 보안그룹
resource "aws_security_group" "ecs_service_sg" {
  name        = "${local.resource_id}-ecs-service-sg"
  description = ""
  vpc_id      = var.vpc_id

  egress {
    description = "allow all TCP"
    from_port   = 65535
    to_port     = 0
    protocol    = "tcp"
  }

  ingress {
    description = ""
    from_port   = var.portforward_host_port
    to_port     = var.portforward_host_port
    protocol    = "tcp"
  }

  tags = local.tags
}

