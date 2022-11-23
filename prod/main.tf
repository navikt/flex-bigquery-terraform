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
  project = var.gcp_project["project"]
  region  = var.gcp_project["region"]
}

data "google_secret_manager_secret_version" "spinnsyn_bigquery_secret" {
  secret = var.spinnsyn_bigquery_secret
}

data "google_project" "project" {}

locals {
  spinnsyn_db = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_bigquery_secret.secret_data
  )

  google_project_iam_member = {
    email = "service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
  }
}

module "google_storage_bucket" {
  source   = "../modules/google-cloud-storage"
  name     = "flex-terraform-state-prod"
  location = var.gcp_project["region"]
}