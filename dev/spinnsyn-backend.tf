data "google_secret_manager_secret_version" "spinnsyn_bigquery_secret" {
  secret = var.spinnsyn_bigquery_secret
}

locals {
  spinnsyn_db = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_bigquery_secret.secret_data
  )
}

module "spinnsyn_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "spinnsyn-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:spinnsyn-backend"
  database      = "spinnsyn-db"
  username      = local.spinnsyn_db.username
  password      = local.spinnsyn_db.password
}

module "spinnsyn_utbetaling" {
  source = "../modules/google-bigquery-table"

  location   = var.gcp_project["region"]
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "spinnsyn_utbetaling"
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

  data_transfer_display_name      = "spinnsyn_utbetaling_query"
  data_transfer_schedule          = "every day 02:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2022-11-10T00:00:00Z"
  data_transfer_destination_table = module.spinnsyn_utbetaling.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.spinnsyn-backend',
'SELECT id, fnr, utbetaling_id, utbetaling_type, utbetaling, opprettet, antall_vedtak, lest, motatt_publisert, skal_vises_til_bruker FROM utbetaling');
EOF

}

module "spinnsyn_utbetaling_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "spinnsyn_utbetaling_view"
  view_schema = jsonencode(
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

  view_query = <<EOF
SELECT utbetaling_id, utbetaling_type, opprettet, antall_vedtak
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.spinnsyn_utbetaling.bigquery_table_id}`
EOF
}

module "spinnsyn_annullering" {
  source = "../modules/google-bigquery-table"

  location   = var.gcp_project["region"]
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
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

module "spinnsyn_annullering_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "spinnsyn_annullering_view"
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
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.spinnsyn_annullering.bigquery_table_id}`
EOF

}