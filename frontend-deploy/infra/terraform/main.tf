terraform {
  backend "gcs" {
    bucket = "{自身のバケット名}"
    prefix = "frontend-deploy"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = "{自身のプロジェクト名}"
}
