locals {
  ecr_repository_name = "test-lambda"  # FIXME
}

resource "aws_ecr_repository" "test_lambda" {
  name = local.ecr_repository_name
}
