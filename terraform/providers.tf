provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "will-tf-state"
    prefix = "terraform"
  }
}