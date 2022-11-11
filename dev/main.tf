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

resource "google_bigquery_table" "spinnsyn_utbetaling" {
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "spinnsyn_utbetaling"

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
        name = "utbetaling"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "opprettet"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "antall_vedtak"
        type = "INTEGER"
      },
      {
        mode = "NULLABLE"
        name = "lest"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "motatt_publisert"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "skal_vises_til_bruker"
        type = "BOOLEAN"
      },
    ]
  )
}

resource "google_bigquery_table" "spinnsyn_utbetaling_view" {
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "spinnsyn_utbetaling_view"

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
        name        = "utbetaling_type"
        type        = "STRING"
        description = "Om det er en UTBETALING, ANNULLERING eller en REVURDERING."
      },
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når utbetalingen ble opprettet."
      },
      {
        mode        = "NULLABLE"
        name        = "antall_vedtak"
        type        = "INTEGER"
        description = "Antall vedtak ubetalingen dekker."
      },
    ]
  )
  view {
    use_legacy_sql = false
    query          = <<EOF
SELECT utbetaling_id, utbetaling_type, opprettet, antall_vedtak
FROM `${var.project}.${google_bigquery_table.spinnsyn_utbetaling.dataset_id}.${google_bigquery_table.spinnsyn_utbetaling.table_id}`
EOF
  }
}

resource "google_bigquery_data_transfer_config" "spinnsyn_utbetaling_query" {
  display_name           = "spinnsyn_utbetaling_query"
  data_source_id         = var.scheduled_query
  location               = var.region
  schedule               = "every day 02:00"
  destination_dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  service_account_name   = "federated-query@${var.project}.iam.gserviceaccount.com"

  schedule_options {
    start_time = "2022-11-10T00:00:00Z"
  }

  params = {
    destination_table_name_template = "spinnsyn_utbetaling"
    write_disposition               = "WRITE_TRUNCATE"
    query                           = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.project}.${var.region}.spinnsyn-backend',
'SELECT id, fnr, utbetaling_id, utbetaling_type, utbetaling, opprettet, antall_vedtak, lest, motatt_publisert, skal_vises_til_bruker FROM utbetaling');
EOF
  }
}

resource "google_bigquery_table" "spinnsyn_annullering" {
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "spinnsyn_annullering"

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
        name = "annullering"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "opprettet"
        type = "TIMESTAMP"
      },
    ]
  )
}

resource "google_bigquery_table" "spinnsyn_annullering_view" {
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "spinnsyn_annullering_view"

  schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "id"
        type        = "STRING"
        description = "Unik ID for annulleringen."
      },
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når annulleringen ble opprettet."
      },
    ]
  )
  view {
    use_legacy_sql = false
    query          = <<EOF
SELECT id, opprettet
FROM `${var.project}.${google_bigquery_table.spinnsyn_annullering.dataset_id}.${google_bigquery_table.spinnsyn_annullering.table_id}`
EOF
  }
}

resource "google_bigquery_data_transfer_config" "spinnsyn_annullering_query" {
  display_name           = "spinnsyn_annullering_query"
  data_source_id         = var.scheduled_query
  location               = var.region
  schedule               = "every day 02:00"
  destination_dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  service_account_name   = "federated-query@${var.project}.iam.gserviceaccount.com"


  schedule_options {
    start_time = "2022-11-10T00:00:00Z"
  }

  params = {
    destination_table_name_template = "spinnsyn_annullering"
    write_disposition               = "WRITE_TRUNCATE"
    query                           = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.project}.${var.region}.spinnsyn-backend',
'SELECT id, fnr, annullering, opprettet FROM annullering');
EOF
  }
}
