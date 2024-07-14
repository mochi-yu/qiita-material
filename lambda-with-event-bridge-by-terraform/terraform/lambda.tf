locals {
  s3_bucket = "mochi-yu-lambda-build"  # FIXME
  s3_key_prefix = "test-lambda"
  s3_base_path = "${local.s3_bucket}/${local.s3_key_prefix}"

  golang_codedir = "${path.module}/../src"

  hash_file_name = "image_digest.txt"
}

resource "aws_lambda_function" "lifecheck_lambda" {
  function_name    = "test-lambda"
  package_type     = "Image"
  image_uri        = "${aws_ecr_repository.test_lambda.repository_url}:latest"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = base64sha256(data.aws_s3_object.image_hash.body)
}

resource "aws_iam_role" "lambda_role" {
  name = "role-for-test_lambda"
  assume_role_policy = file("lambda-assume-role.json")
}

resource "null_resource" "lambda_build" {
  depends_on = [ aws_ecr_repository.test_lambda ]

  triggers = {
    code_diff = sha256(join("", [
      for file in fileset(local.golang_codedir, "*")
      : filesha256("${local.golang_codedir}/${file}")
    ]))
  }

  # イメージのビルド
  provisioner "local-exec" {
    command = "cd ${path.module}/.. && docker build . -f docker/Dockerfile --platform linux/amd64 -t ${aws_ecr_repository.test_lambda.repository_url}:latest"
  }

  # イメージをECRへプッシュ
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.test_lambda.repository_url} && docker push ${aws_ecr_repository.test_lambda.repository_url}:latest"
  }

  # ハッシュの生成
  provisioner "local-exec" {
    command = "cd ${path.module}/.. && docker inspect --format='{{index .RepoDigests 0}}' ${aws_ecr_repository.test_lambda.repository_url}:latest > ${local.hash_file_name}"
  }

  # ハッシュのs3へのアップロード
  provisioner "local-exec" {
    command = "cd ${path.module}/.. && aws s3 cp ${local.hash_file_name} s3://${local.s3_base_path}/${local.hash_file_name} --content-type \"text/plain\""
  }
}

data "aws_s3_object" "image_hash" {
  depends_on = [null_resource.lambda_build]

  bucket = local.s3_bucket
  key    = "${local.s3_key_prefix}/${local.hash_file_name}"
}
