terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.44.0"
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

data "google_project" "project" {}

locals {
  google_project_iam_member = {
    email = "service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
  }
}

module "google_storage_bucket" {
  source   = "../modules/google-cloud-storage"
  name     = "flex-terraform-state-prod"
  location = var.gcp_project["region"]
}