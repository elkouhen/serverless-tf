resource "aws_cognito_user_pool" "pool" {
  name = "${var.env}-userpool"
}

resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.env}-userpool"
}

resource "aws_cognito_resource_server" "resource_server" {
  name         = "${var.env}-resource-server"
  identifier   = "https://helloworld.${var.env}.sbx.aws.ippon.fr"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  scope {
    scope_name        = "all"
    scope_description = "Get access to all API Gateway endpoints."
  }
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain = "helloworld-${var.env}"
  # certificate_arn = "${module.acm_certificate.this_acm_certificate_arn}"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "${var.env}-client"
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  generate_secret                      = true
  allowed_oauth_flows                  = ["client_credentials"]
  supported_identity_providers         = ["COGNITO"]

  depends_on = [
    "aws_cognito_user_pool.user_pool",
    "aws_cognito_resource_server.resource_server",
  ]
}
