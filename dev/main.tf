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

data "google_secret_manager_secret_version" "spinnsyn_db_bigquery" {
  secret = "spinnsyn-db-bigquery"
}

data "google_client_config" "current" {}

data "google_project" "project" {}

locals {
  spinnsyn_db = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_db_bigquery.secret_data
  )
  google_bigquery_data_transfer_config = {
    data_source_id = "scheduled_query"
  }
}

resource "google_storage_bucket" "terraform" {
  name          = "flex-terraform-state-dev"
  location      = data.google_client_config.current.region
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

resource "google_service_account" "federated_query" {
  account_id   = "federated-query"
  description  = "Service Account brukt av BigQuery Scheduled Queries."
  display_name = "Federated Query"
}

resource "google_bigquery_connection" "spinnsyn_backend" {
  connection_id = "spinnsyn-backend"
  location      = data.google_client_config.current.region

  cloud_sql {
    instance_id = "${data.google_project.project.project_id}:${data.google_client_config.current.region}:spinnsyn-backend"
    database    = "spinnsyn-db"
    type        = "POSTGRES"
    credential {
      username = local.spinnsyn_db.username
      password = local.spinnsyn_db.password
    }
  }
}

resource "google_bigquery_dataset" "flex_dataset" {
  dataset_id = "flex_dataset"
  location   = data.google_client_config.current.region

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
}

resource "google_bigquery_table" "spinnsyn_utbetalinger" {
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "spinnsyn_utbetalinger"

  schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "fnr"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "utbetaling_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "utbetaling_type"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "antall_vedtak"
        type = "INTEGER"
      },
    ]
  )
}

resource "google_bigquery_table" "spinnsyn_utbetalinger_view" {
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "spinnsyn_utbetalinger_view"

  schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "utbetaling_id"
        type        = "STRING"
        description = "Unik ID for utbetalingen."
      },
      {
        mode        = "NULLABLE"
        name        = "antall_vedtak"
        type        = "INTEGER"
        description = "Antall vedtak tilhørende utbetalingen."
      }
    ]
  )
  view {
    use_legacy_sql = false
    query          = <<EOF
SELECT utbetaling_id, antall_vedtak
FROM `${data.google_project.project.project_id}.flex_dataset.spinnsyn_utbetalinger`
EOF
  }
}

resource "google_bigquery_data_transfer_config" "spinnsyn_utbetalinger_query" {
  display_name           = "spinnsyn_utbetalinger_query"
  data_source_id         = local.google_bigquery_data_transfer_config.data_source_id
  schedule               = "every day 02:00"
  destination_dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  service_account_name   = "federated-query@${data.google_project.project.project_id}.iam.gserviceaccount.com"

  params = {
    destination_table_name_template = "spinnsyn_utbetalinger"
    write_disposition               = "WRITE_TRUNCATE"
    query                           = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${data.google_project.project.project_id}.${data.google_client_config.current.region}.spinnsyn-backend',
'SELECT id, fnr, utbetaling_id, utbetaling_type, antall_vedtak FROM utbetaling');
EOF
  }
}
