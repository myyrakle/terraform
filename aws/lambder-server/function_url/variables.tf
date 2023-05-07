// 리전
variable "region" {
  description = "region"
  type        = string
}

// tag 및 리소스 이름 구성에 사용됨
variable "environment" {
  description = "environment info. (e.g: prod, dev, stage, test)"
  type        = string
}

// 서버명 (server_name-environment 형태로 구성됩니다.)
variable "server_name" {
  description = "The name of the server machine you want to create."
  type        = string
}
