terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.41.0"
    }
  }

  backend "gcs" {
    bucket = "flex-terraform-state-dev"
  }
}

provider "google" {
  project = "flex-dev-2b16"
  region  = "europe-north1"
}

resource "google_storage_bucket" "terraform" {
  name          = "flex-terraform-state-dev"
  location      = "europe-north1"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "terraform-test" {
  name          = "flex-terraform-test-op7sdf98"
  force_destroy = true
  location      = "europe-north1"
  storage_class = "STANDARD"
}