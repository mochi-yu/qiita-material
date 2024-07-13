locals {
  s3_bucket = "hoge"  # FIXME
  s3_key_prefix = "test-lambda"
  s3_base_path = "${local.s3_bucket}/${local.s3_key_prefix}"

  golang_codedir = "${path.module}/../src"
  binary_file_name = "bootstrap"
  zip_file_name  = "archive.zip"
  hash_file_name = "archive_hash.txt"

  binary_file_path = "${local.golang_codedir}/../bin/${local.binary_file_name}"
  zip_file_path = "${local.golang_codedir}/../archive/${local.zip_file_name}"
  hash_file_path = "${local.golang_codedir}/../archive/${local.hash_file_name}"
}

resource "aws_lambda_function" "lifecheck_lambda" {
  function_name    = "test-lambda"
  s3_bucket        = local.s3_bucket
  s3_key           = data.aws_s3_object.zip.key
  role             = aws_iam_role.lambda_role.arn
  handler          = "bootstrap"
  source_code_hash = data.aws_s3_object.zip_hash.body
  runtime          = "provided.al2"
}

resource "aws_iam_role" "lambda_role" {
  name = "role-for-test_lambda"
  assume_role_policy = file("lambda-assume-role.json")
}

resource "null_resource" "lambda_build" {
  triggers = {
    code_diff = join("", [
      for file in fileset(local.golang_codedir, "**/{*.go,go.mod,go.sum}")
      : filesha256("${local.golang_codedir}/${file}")
    ])
  }

  # コードのビルド
  provisioner "local-exec" {
    command = "cd ${local.golang_codedir} && CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -tags lambda.norpc -o ../bin/${local.binary_file_name} ./*.go"
  }

  # バイナリのzip化
  provisioner "local-exec" {
    command = "zip -j ${local.zip_file_path} ${local.binary_file_path}"
  }

  # バイナリのs3へのアップロード
  provisioner "local-exec" {
    command = "aws s3 cp ${local.zip_file_path} s3://${local.s3_base_path}/${local.zip_file_name}"
  }

  # ハッシュの生成
  provisioner "local-exec" {
    command = "openssl dgst -sha256 -binary ${local.zip_file_path} | openssl enc -base64 | tr -d \"\n\" > ${local.hash_file_path}"
  }

  # ハッシュのs3へのアップロード
  provisioner "local-exec" {
    command = "aws s3 cp ${local.hash_file_path} s3://${local.s3_base_path}/${local.hash_file_name} --content-type \"text/plain\""
  }
}

data "aws_s3_object" "zip" {
  depends_on = [null_resource.lambda_build]

  bucket = local.s3_bucket
  key    = "${local.s3_key_prefix}/${local.zip_file_name}"
}

data "aws_s3_object" "zip_hash" {
  depends_on = [null_resource.lambda_build]

  bucket = local.s3_bucket
  key    = "${local.s3_key_prefix}/${local.hash_file_name}"
}
