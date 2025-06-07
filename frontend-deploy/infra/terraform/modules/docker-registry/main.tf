resource "google_artifact_registry_repository" "docker-registry" {
  format = "DOCKER"
  location = "asia-northeast1"

  repository_id = var.repository_id
  description = var.description

  docker_config {
    immutable_tags = false
  }

  # クリーンアップの設定
  cleanup_policy_dry_run = false

  cleanup_policies {
    id = "keep-latest-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 3
    }
  }

  cleanup_policies {
    id = "delete-old-versions"
    action = "DELETE"
    condition {
      older_than = "5d"
    }

  }
}
