module "example_site" {
  source = "./modules"
  domain = "example.com"
  env = "prod"
}

module "example1_site" {
  source = "./modules"
  domain = "example1.com"
  env = "prod"
}

terraform {
  backend "s3" {
    region = "ap-northeast-1"
    encrypt = false
    bucket  = "example"
    key     = "static-site/prod"
  }
}
