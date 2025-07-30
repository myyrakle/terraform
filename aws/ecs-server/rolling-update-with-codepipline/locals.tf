data "aws_caller_identity" "current" {}

locals {
  tags = {
    Environment = var.environment
    Application = var.server_name
  }

  resource_id = join("-", [var.server_name, var.environment])

  account_id = data.aws_caller_identity.current.account_id

  release_image = join(":", [aws_ecr_repository.ecr.repository_url, var.docker_release_tag])
}
