data "aws_region" "current" {}

data "template_file" "api" {
  template = file("${path.module}/spec.yaml")

  vars = {
    helloworld_arn = var.helloworld_arn
    aws_region     = data.aws_region.current.name
    userpool_arn   = var.userpool_arn
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name           = "helloworld-${var.env}-api"
  api_key_source = "HEADER"

  body = data.template_file.api.rendered
}


resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "allow-api-invoke"
  action        = "lambda:InvokeFunction"
  function_name = "helloworld-${var.env}-lambda"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}

resource "aws_api_gateway_authorizer" "api_authorizer" {
  name        = "CognitoUserPoolAuthorizer"
  type        = "COGNITO_USER_POOLS"
  rest_api_id = aws_api_gateway_rest_api.api.id

  provider_arns = [var.userpool_arn]
}
