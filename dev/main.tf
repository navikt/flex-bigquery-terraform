terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.55.0"
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

data "google_secret_manager_secret_version" "sykepengesoknad_sak_status_bigquery_secret" {
  secret = var.sykepengesoknad_sak_status_bigquery_secret
}

locals {
  sak_status_metrikk_db = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_sak_status_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "sykepengesoknad_bigquery_secret" {
  secret = var.sykepengesoknad_bigquery_secret
}

locals {
  sykepengesoknad_db = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "spinnsyn_bigquery_secret" {
  secret = var.spinnsyn_bigquery_secret
}

locals {
  spinnsyn_db = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "arkivering_oppgave_bigquery_secret" {
  secret = var.arkivering_oppgave_bigquery_secret
}

locals {
  arkivering_oppgave_db = jsondecode(
    data.google_secret_manager_secret_version.arkivering_oppgave_bigquery_secret.secret_data
  )
}

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
  description  = "Service Account brukt av BigQuery Scheduled Queries."
  display_name = "Federated Query"
}

resource "google_project_iam_member" "permissions" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountShortTermTokenMinter"
  member  = "serviceAccount:${local.google_project_iam_member.email}"
}
