terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.16.0"
    }
  }

  backend "gcs" {
    bucket = "flex-terraform-state-dev"
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
  source = "../modules/google-cloud-storage"

  name     = "flex-terraform-state-dev"
  location = var.gcp_project["region"]
}

resource "google_service_account" "federated_query" {
  account_id   = "federated-query"
  description  = "Service Account brukt av BigQuery Federated (Scheduled) Queries."
  display_name = "Federated Query"
}

resource "google_project_iam_member" "permissions" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountShortTermTokenMinter"
  member  = "serviceAccount:${local.google_project_iam_member.email}"
}
