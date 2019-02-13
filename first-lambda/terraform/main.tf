//config provider
provider "aws" {
  region     = "ap-southeast-1"
  profile    = "default"
}
//
// create resource
//
resource "aws_iam_role" "first_lambda_role" {
  name = "first_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}

# Build and publish source code
data "archive_file" "zipfile" {
  type        = "zip"
  source_dir  = "../myProject/src/aws-lambda-function/bin/Release/netcoreapp2.1/publish"
  output_path = "../myProject/src/zip/deployment.zip"
}

#Config and deploy lambda
resource "aws_lambda_function" "lambda" {
  depends_on        = ["aws_iam_role.first_lambda_role"]
  filename          = "../myProject/src/zip/deployment.zip"
  function_name     = "first-lambda"
  role              = "${aws_iam_role.first_lambda_role.arn}"
  handler           = "aws-lambda-function::aws_lambda_function.Function::FunctionHandler"
  runtime           = "dotnetcore2.1"
  source_code_hash  = "${base64sha256(file("${data.archive_file.zipfile.output_path}"))}"
  memory_size       = 256
  timeout           = 60
}

#
#
#
#
#
# api gateway
#
#
#
#
#
# locals {
#   name              = "${var.name}"
#   stage_name        = "${var.stage_name}"
#   resource_name     = "${var.resource_name}"
#   method            = "${var.method}"
#   region            = "${var.region}"
#   lambda_arn        = "${var.lambda_arn}"
#   lambda_invoke_arn = "${var.lambda_invoke_arn}"
#   lambda_version    = "${var.lambda_version}"
# }

# create api name
resource "aws_api_gateway_rest_api" "api" {
  depends_on = ["aws_lambda_function.lambda"]
  name = "first_api"
}

# create resource api #ex www.test.com/resource
resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "first_resource"
}

# create method
resource "aws_api_gateway_method" "request_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.my_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

# integration 
resource "aws_api_gateway_integration" "request_method_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.my_resource.id}"
  http_method = "${aws_api_gateway_method.request_method.http_method}"
  type        = "AWS_PROXY"
  uri         = "arn:aws:apigateway:ap-southeast-1:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"

  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "POST"
}

# lambda => GET response
resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.my_resource.id}"
  http_method = "${aws_api_gateway_integration.request_method_integration.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.my_resource.id}"
  http_method = "${aws_api_gateway_method_response.response_method.http_method}"
  status_code = "${aws_api_gateway_method_response.response_method.status_code}"

  response_templates = {
    "application/json" = ""
  }
}

# deployment api & select stage
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "dev"
  depends_on  = [
      "aws_api_gateway_integration.request_method_integration",
      "aws_api_gateway_method.request_method",
      "aws_api_gateway_integration_response.response_method_integration",
      "aws_api_gateway_method_response.response_method"
      ]
}

resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = "${aws_lambda_function.lambda.arn}"
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  # source_arn    = "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.api.id}/*/${local.method}${aws_api_gateway_resource.proxy.path}"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
  depends_on    = ["aws_api_gateway_rest_api.api", "aws_api_gateway_resource.my_resource"]
}

