data "archive_file" "function_archive" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/helloworld/built"
  output_path = "${path.module}/../../../iac/dev/builds/helloworld.zip"
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "helloworld-lambda"
  
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  create_package         = false
  local_existing_package = data.archive_file.function_archive.output_path
  
}