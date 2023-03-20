data "aws_region" "current" {}

data "template_file" "api" {
  template = file("${path.module}/spec.yaml")

  vars = {
    helloworld_arn = var.helloworld_arn
    aws_region     = data.aws_region.current.name
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name           = "helloworld-${var.env}-api"
  api_key_source = "HEADER"

  body = data.template_file.api.rendered
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "allow-api-invoke"
  action        = "lambda:InvokeFunction"
  function_name = "helloworld-${var.env}-lambda"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}