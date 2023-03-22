data "archive_file" "function_archive" {

  type        = "zip"
  source_dir  = "${path.module}/../../../src/${var.module_name}/builds"
  output_path = "${path.module}/../../../iac/${var.env}/builds/${var.module_name}.zip"
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "4.12.1"

  function_name = "${var.module_name}-${var.env}-lambda"

  handler = "index.handler"
  runtime = "nodejs18.x"

  create_package         = false
  local_existing_package = data.archive_file.function_archive.output_path
}