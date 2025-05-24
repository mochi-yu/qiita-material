module "app" {
  source = "../../modules"
  env = "prod"
}

terraform {
  backend "s3" {
    region  = "ap-northeast-1"
    encrypt = false
    # bucket  = "XXXXXXXXXXXXXXX"
    # key     = "XXXXXXXXXXXXXXX"
  }
}
