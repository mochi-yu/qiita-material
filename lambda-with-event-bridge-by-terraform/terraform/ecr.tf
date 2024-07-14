locals {
  ecr_repository_name = "mochi-yu-test-lambda"
}

resource "aws_ecr_repository" "test_lambda" {
  name = local.ecr_repository_name
}
