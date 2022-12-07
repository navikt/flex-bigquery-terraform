data "google_secret_manager_secret_version" "arkivering_oppgave_bigquery_secret" {
  secret = var.arkivering_oppgave_bigquery_secret
}

locals {
  arkivering_oppgave_db = jsondecode(
    data.google_secret_manager_secret_version.arkivering_oppgave_bigquery_secret.secret_data
  )
}

module "spinnsyn_arkivering_oppgave_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-arkivering-oppgave"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad-arkivering-oppgave"
  database      = "sykepengesoknad-arkivering-oppgave-db"
  username      = local.arkivering_oppgave_db.username
  password      = local.arkivering_oppgave_db.password
}

module "sykepengesoknad_arkivering_oppgave_innsending" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_arkivering_oppgave_innsending"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "journalpost_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "oppgave_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "behandlet"
        type = "TIMESTAMP"
      },
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_arkivering_oppgave_innsending_query"
  data_transfer_schedule          = "every day 02:30"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2022-12-07T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_arkivering_oppgave_innsending.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-arkivering-oppgave',
'SELECT id, sykepengesoknad_id, journalpost_id, oppgave_id, behandlet FROM innsending');
EOF

}

module "sykepengesoknad_arkivering_oppgave_innsending_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykepengesoknad_arkivering_oppgave_innsending_view"
  view_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "journalpost_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "oppgave_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "behandlet"
        type = "TIMESTAMP"
      },
    ]
  )

  view_query = <<EOF
SELECT sykepengesoknad_id, journalpost_id, oppgave_id, behandlet
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_arkivering_oppgave_innsending.bigquery_table_id}`
EOF

}

module "sykepengesoknad_arkivering_oppgave_oppgavestyring" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_arkivering_oppgave_oppgavestyring"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "status"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "opprettet"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "modifisert"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "timeout"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "avstemt"
        type = "BOOLEAN"
      },
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_arkivering_oppgave_oppgavestyring_query"
  data_transfer_schedule          = "every day 02:45"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2022-12-07T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_arkivering_oppgave_oppgavestyring.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-arkivering-oppgave',
'SELECT id, sykepengesoknad_id, status, opprettet, modifisert, timeout, avstemt FROM oppgavestyring');
EOF

}

module "sykepengesoknad_arkivering_oppgave_oppgavestyring_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykepengesoknad_arkivering_oppgave_oppgavestyring_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_id"
        type        = "STRING"
        description = "Unik ID for sykepengesoknaden."
      },
      {
        mode        = "NULLABLE"
        name        = "status"
        type        = "STRING"
        description = "Status som forteller om det skal opprettet oppgave eller om vi venter på melding fra Speil."
      },
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når status ble opprettet."
      },
      {
        mode        = "NULLABLE"
        name        = "modifisert"
        type        = "TIMESTAMP"
        description = "Når status sist ble modifisert."
      },
      {
        mode        = "NULLABLE"
        name        = "timeout"
        type        = "TIMESTAMP"
        description = "Tidspunkt for når vi har ventet for lenge og opprettet Gosys-oppgave uansett."
      }
    ]
  )

  view_query = <<EOF
SELECT sykepengesoknad_id, status, opprettet, modifisert, timeout
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_arkivering_oppgave_oppgavestyring.bigquery_table_id}`
WHERE avstemt = true
EOF

}
