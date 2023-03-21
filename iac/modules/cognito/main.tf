resource "aws_cognito_user_pool" "pool" {
  name = "${var.env}-userpool"
}

resource "aws_cognito_resource_server" "resource_server" {
  name         = "${var.env}-resource-server"
  identifier   = "helloworld-${var.env}.sbx.aws.ippon.fr"
  user_pool_id = aws_cognito_user_pool.pool.id

  scope {
    scope_name        = "all"
    scope_description = "Get access to all API Gateway endpoints."
  }
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain = "helloworld-${var.env}"
  
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "client" {
  name            = "${var.env}-client"
  user_pool_id    = aws_cognito_user_pool.pool.id
  generate_secret = true

  callback_urls                = ["https://helloworld-${var.env}.sbx.aws.ippon.fr/login"]
  allowed_oauth_flows          = ["code"]
  allowed_oauth_scopes         = ["openid", "email"]
  supported_identity_providers = ["COGNITO"]

  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cognito_resource_server.resource_server,
  ]
}
