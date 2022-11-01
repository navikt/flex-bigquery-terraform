terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.41.0"
    }
  }
  backend "gcs" {
    bucket = "flex-terraform-state-prod"
  }
}

provider "google" {
  project = "flex-prod-af40"
  region  = "europe-north1"
}

resource "google_storage_bucket" "terraform" {
  name          = "flex-terraform-state-prod"
  location      = "europe-north1"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}