# No need for a backend here as well just store state locally

provider "google" {
  project = var.project_id
  region  = var.secondary_region
}

data "google_client_config" "current" {}

data "google_project" "project" {
  project_id = var.project_id
}

output "project" {
  value = data.google_client_config.current.project
}
