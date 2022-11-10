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
  project = var.project
  region  = var.region
}

data "google_secret_manager_secret_version" "spinnsyn_db_bigquery" {
  secret = var.spinnsyn_db_secret
}

data "google_project" "project" {}

locals {
  spinnsyn_db = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_db_bigquery.secret_data
  )

  google_project_iam_member = {
    email = "service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
  }
}

resource "google_storage_bucket" "terraform" {
  name          = "flex-terraform-state-dev"
  location      = var.region
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

resource "google_project_iam_member" "permissions" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountShortTermTokenMinter"
  member  = "serviceAccount:${local.google_project_iam_member.email}"
}

resource "google_bigquery_connection" "spinnsyn_backend" {
  connection_id = "spinnsyn-backend"
  location      = var.region

  cloud_sql {
    instance_id = "${var.project}:${var.region}:spinnsyn-backend"
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
  location   = var.region

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
    user_by_email = local.google_project_iam_member.email
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
  data_source_id         = var.scheduled_query
  location               = var.region
  schedule               = "every day 02:00"
  destination_dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  service_account_name   = "federated-query@${var.project}.iam.gserviceaccount.com"


  schedule_options {
    start_time = "2022-11-09T00:00:00Z"
  }

  params = {
    destination_table_name_template = "spinnsyn_utbetalinger"
    write_disposition               = "WRITE_TRUNCATE"
    query                           = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.project}.${var.region}.spinnsyn-backend',
'SELECT id, fnr, utbetaling_id, utbetaling_type, antall_vedtak FROM utbetaling');
EOF
  }
}