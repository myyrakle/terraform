// 리전
variable "region" {
  description = "region"
  type        = string
}


// tag에 사용됨
variable "environment" {
  description = "environment info. (e.g: prod, dev, stage, test)"
  type        = string
}


// 서버명
variable "server_name" {
  description = "The name of the server machine you want to create."
  type        = string
}

# variable "github_repository" {
#   description = "The name of the github repository."
#   type        = string
# }

# variable "github_branch" {
#   description = "The name of the github branch."
#   type        = string
# }

# variable "github_oauth_token" {
#   description = "The oauth token for github. (e.g: ghp_KZymx3mI6f3x*****5GN3W5RItAB1fzlyi)"
#   type        = string
# }

# variable "vpc_id" {
#   description = "VPC ID. That VPC must have at least 2 subnets for availability. (e.g: vpc-053f9aaabecf3b6bc)"
#   type        = string
# }

# variable "subnet_ids" {
#   description = "Subnet IDs. (e.g: [subnet-0a9b8c7d6e5f4a3b2, subnet-0a9b8c7d6e5f4a3b2])"
#   type        = list(string)
# }
# variable "certificate_arn" {
#   description = "The ARN of the certificate to use for SSL. (e.g: arn:aws:acm:ap-northeast-2:210706881319:certificate/6a0b3a8b-bcb1-491d-a814-078739105983)"
#   type        = string
# }

# variable "docker_entrypoint" {
#   description = "The entrypoint of the docker image. (e.g: \"sh\", \"run.sh\")"
#   type        = string
# }

# variable "healthcheck_uri" {
#   description = "The uri of the healthcheck. (e.g: \"/health\")"
#   type        = string
# }

# variable "buildspec_path" {
#   description = "BuildSpec file path (e.g: \"/prod/buildspec.yml\")"
#   type        = string
# }
