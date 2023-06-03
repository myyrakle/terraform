// Lambda Role
resource "aws_iam_role" "lambda_role" {
  name = "${local.resource_id}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["lambda.amazonaws.com"]
        },
        "Action" : [
          "sts:AssumeRole"
        ]
      }
    ]
  })

  inline_policy {
    name = "root"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Sid" : "SpecificTable",
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:BatchGet*",
            "dynamodb:DescribeStream",
            "dynamodb:DescribeTable",
            "dynamodb:Get*",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:BatchWrite*",
            "dynamodb:CreateTable",
            "dynamodb:Delete*",
            "dynamodb:Update*",
            "dynamodb:PutItem"
          ],
          "Resource" : [
            // 테이블을 추가할 때마다 여기에도 리소스를 추가해줍니다.
            "arn:aws:dynamodb:*:*:table/${local.resource_id}_connection"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "lambda-basic-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-access-gateway-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

data "aws_iam_policy_document" "api_gateway_policy" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    effect = "Allow"
    resources = [
      aws_lambda_function.connect_lambda.arn,
      aws_lambda_function.disconnect_lambda.arn,
      aws_lambda_function.default_lambda.arn
    ]
  }
}

resource "aws_iam_policy" "api_gateway_policy" {
  name   = "${local.resource_id}-gateway-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.api_gateway_policy.json
}

resource "aws_iam_role" "api_gateway_role" {
  name = "${local.resource_id}-gateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [aws_iam_policy.api_gateway_policy.arn]
}

