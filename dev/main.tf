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

resource "google_service_account" "federated-query" {
  account_id   = "federated-query"
  description  = "Bruker til federated query for å oppdatere BigQuery datasett"
  display_name = "Federated Query"
}

data "google_secret_manager_secret_version" "spinnsyn_db_bigquery" {
  secret = "spinnsyn-db-bigquery"
}
locals {
  spinnsyn_db = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_db_bigquery.secret_data
  )
}

resource "google_bigquery_connection" "spinnsyn-backend" {
  connection_id = "spinnsyn-backend"
  location      = "europe-north1"

  cloud_sql {
    instance_id = "flex-dev-2b16:europe-north1:spinnsyn-backend"
    database    = "spinnsyn-db"
    type        = "POSTGRES"
    credential {
      username = local.spinnsyn_db.username
      password = local.spinnsyn_db.password
    }
  }
}

