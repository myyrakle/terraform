locals {
  resource_name = join("-", [var.environment, var.service_name])
}