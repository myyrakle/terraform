resource "aws_s3_bucket" "artifact_bucket" {
  tags = local.tags
}

resource "aws_s3_bucket" "cache_bucket" {
  tags = local.tags
}

resource "aws_codebuild_project" "codebuild" {
  name          = local.resource_id
  description   = "code build"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type     = "S3"
    location = aws_s3_bucket.artifact_bucket.bucket
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.cache_bucket.bucket
  }

  environment {
    compute_type                = var.codebuild_compute_type
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.ecr.name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = var.docker_release_tag
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.account_id
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "EnvironmentName"
      value = local.resource_id
    }
  }

  source {
    type      = "S3"
    location  = "${ArtifactBucket}/source.zip"
    buildspec = var.buildspec_path
  }

  timeout_in_minutes = 30

  tags = local.tags
}
