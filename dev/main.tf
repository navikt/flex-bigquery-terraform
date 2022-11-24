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

module "google_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "spinnsyn-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:spinnsyn-backend"
  database      = "spinnsyn-db"
  username      = local.spinnsyn_db.username
  password      = local.spinnsyn_db.password
}

module "google_bigquery_dataset" {
  source = "../modules/google-bigquery-dataset"

  dataset_id         = "flex_dataset"
  location           = var.gcp_project["region"]
  dataset_iam_member = local.google_project_iam_member.email
}

resource "google_bigquery_table" "spinnsyn_utbetaling" {
  dataset_id = module.google_bigquery_dataset.dataset_id
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
  dataset_id = module.google_bigquery_dataset.dataset_id
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
FROM `${var.gcp_project["project"]}.${google_bigquery_table.spinnsyn_utbetaling.dataset_id}.${google_bigquery_table.spinnsyn_utbetaling.table_id}`
EOF
  }
}

resource "google_bigquery_data_transfer_config" "spinnsyn_utbetaling_query" {
  display_name           = "spinnsyn_utbetaling_query"
  data_source_id         = var.scheduled_query_data_source_id
  location               = var.gcp_project["region"]
  schedule               = "every day 02:00"
  destination_dataset_id = module.google_bigquery_dataset.dataset_id
  service_account_name   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"

  schedule_options {
    start_time = "2022-11-10T00:00:00Z"
  }

  params = {
    destination_table_name_template = "spinnsyn_utbetaling"
    write_disposition               = "WRITE_TRUNCATE"
    query                           = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.spinnsyn-backend',
'SELECT id, fnr, utbetaling_id, utbetaling_type, utbetaling, opprettet, antall_vedtak, lest, motatt_publisert, skal_vises_til_bruker FROM utbetaling');
EOF
  }
}

module "spinnsyn_annullering" {
  source = "../modules/google-bigquery-table"

  location   = var.gcp_project["region"]
  dataset_id = module.google_bigquery_dataset.dataset_id
  table_id   = "spinnsyn_annullering"
  table_schema = jsonencode(
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

  view_id = "spinnsyn_annullering_view"
  view_schema = jsonencode(
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

  view_query = <<EOF
SELECT id, opprettet
FROM `${var.gcp_project["project"]}.${module.google_bigquery_dataset.dataset_id}.${module.spinnsyn_annullering.bigquery_table_id}`
EOF

  data_transfer_display_name      = "spinnsyn_annullering_query"
  data_transfer_schedule          = "every day 02:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2022-11-10T00:00:00Z"
  data_transfer_destination_table = module.spinnsyn_annullering.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.spinnsyn-backend',
'SELECT id, fnr, annullering, opprettet FROM annullering');
EOF

}

