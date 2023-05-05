resource "aws_iam_role" "task_execution_role" {
  name = join("-", [var.server_name, var.environment, "task-execution-role"])

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["ecs-tasks.amazonaws.com"]
        },
        "Action" : ["sts:AssumeRole"]
      }
    ]
    Path = "/"
    Policies = [
      {
        "PolicyName" : "root",
        "PolicyDocument" : {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : "*",
              "Resource" : "*"
            }
          ]
        }
      }
    ]
  })

  tags = local.tags
}

