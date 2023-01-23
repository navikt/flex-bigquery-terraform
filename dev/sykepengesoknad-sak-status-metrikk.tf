data "google_secret_manager_secret_version" "sykepengesoknad_sak_status_bigquery_secret" {
  secret = var.sykepengesoknad_sak_status_bigquery_secret
}

locals {
  sak_status_metrikk_db = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_sak_status_bigquery_secret.secret_data
  )
}

module "sykepengesoknad_sak-status-metrikk-bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-sak-status-metrikk"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad-sak-status-metrikk"
  database      = "sykepengesoknad-sak-status-metrikk-db"
  username      = local.sak_status_metrikk_db.username
  password      = local.sak_status_metrikk_db.password
}

module "sykepengesoknad_sak_status_metrikk_sykepengesoknad_id" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_sak_status_metrikk_sykepengesoknad_id"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_uuid"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_at_id"
        type = "STRING"
      },
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_sak_status_metrikk_sykepengesoknad_id_query"
  data_transfer_schedule          = "every day 02:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-01-23T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_sak_status_metrikk_sykepengesoknad_id.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-sak-status-metrikk',
'SELECT sykepengesoknad_uuid, sykepengesoknad_at_id FROM sykepengesoknad_id');
EOF

}