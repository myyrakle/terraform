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
