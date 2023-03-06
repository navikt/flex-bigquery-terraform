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
  data_transfer_start_time        = "2022-11-26T00:00:00Z"
  data_transfer_destination_table = module.spinnsyn_utbetaling.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.spinnsyn-backend',
'SELECT id, fnr, utbetaling_id, utbetaling_type, utbetaling, opprettet, antall_vedtak, lest, motatt_publisert, skal_vises_til_bruker FROM utbetaling');
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
  data_transfer_start_time        = "2022-11-26T00:00:00Z"
  data_transfer_destination_table = module.spinnsyn_annullering.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.spinnsyn-backend',
'SELECT id, fnr, annullering, opprettet FROM annullering');
EOF

}

module "spinnsyn_done_vedtak" {
  source = "../modules/google-bigquery-table"

  location   = var.gcp_project["region"]
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "spinnsyn_done_vedtak"
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
        name = "type"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "done_sendt"
        type = "TIMESTAMP"
      },
    ]
  )

  data_transfer_display_name      = "spinnsyn_done_vedtak_query"
  data_transfer_schedule          = "every day 02:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2022-11-26T00:00:00Z"
  data_transfer_destination_table = module.spinnsyn_done_vedtak.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.spinnsyn-backend',
'SELECT id, fnr, type, done_sendt FROM done_vedtak');
EOF

}

module "spinnsyn_organisasjon" {
  source = "../modules/google-bigquery-table"

  location   = var.gcp_project["region"]
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "spinnsyn_organisasjon"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "orgnummer"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "navn"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "opprettet"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "oppdatert"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "oppdatert_av"
        type = "STRING"
      },
    ]
  )

  data_transfer_display_name      = "spinnsyn_organisasjon_query"
  data_transfer_schedule          = "every day 02:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2022-11-26T00:00:00Z"
  data_transfer_destination_table = module.spinnsyn_organisasjon.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.spinnsyn-backend',
'SELECT id, orgnummer, navn, opprettet, oppdatert, oppdatert_av FROM organisasjon');
EOF

}

module "spinnsyn_vedtak" {
  source = "../modules/google-bigquery-table"

  location   = var.gcp_project["region"]
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "spinnsyn_vedtak"
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
        name = "vedtak"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "opprettet"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "utbetaling_id"
        type = "STRING"
      },
    ]

  )

  data_transfer_display_name      = "spinnsyn_vedtak_query"
  data_transfer_schedule          = "every day 02:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2022-11-26T00:00:00Z"
  data_transfer_destination_table = module.spinnsyn_vedtak.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.spinnsyn-backend',
'SELECT id, fnr, vedtak, opprettet, utbetaling_id FROM vedtak_v2');
EOF

}