module "spinnsyn_utbetaling_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "spinnsyn_utbetaling_view"
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
        name        = "motatt_publisert"
        type        = "TIMESTAMP"
        description = "motatt_publisert"
      },
      {
        mode        = "NULLABLE"
        name        = "lest"
        type        = "TIMESTAMP"
        description = "når vedtaket er lest"
      },
      {
        mode        = "NULLABLE"
        name        = "skal_vises_til_bruker"
        type        = "BOOLEAN"
        description = "når vedtaket er lest"
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
SELECT utbetaling_id, utbetaling_type, opprettet, motatt_publisert, lest, skal_vises_til_bruker, antall_vedtak
FROM `${var.gcp_project["project"]}.${module.spinnsyn_datastream.dataset_id}.public_utbetaling`
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
FROM `${var.gcp_project["project"]}.${module.spinnsyn_datastream.dataset_id}.public_annullering`
EOF
}

module "spinnsyn_done_vedtak_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id

  view_id = "spinnsyn_done_vedtak_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "id"
        type        = "STRING"
        description = "Unik ID for done-meldingen."
      },
      {
        mode        = "NULLABLE"
        name        = "type"
        type        = "STRING"
        description = "Om done-meldingen gjelder VEDTAK eller UTBETALING."
      },
      {
        mode        = "NULLABLE"
        name        = "done_sendt"
        type        = "TIMESTAMP"
        description = "Når done-melding ble sendt."
      },
    ]
  )

  view_query = <<EOF
SELECT id, type, done_sendt
FROM `${var.gcp_project["project"]}.${module.spinnsyn_datastream.dataset_id}.public_done_vedtak`
EOF
}

module "spinnsyn_organisasjon_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "spinnsyn_organisasjon_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "id"
        type        = "STRING"
        description = "Unik ID for organisasjonen."
      },
      {
        mode        = "NULLABLE"
        name        = "orgnummer"
        type        = "STRING"
        description = "Organisasjonens orgnummer."
      },
      {
        mode        = "NULLABLE"
        name        = "navn"
        type        = "STRING"
        description = "Organisasjonens navn."
      },
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når organisasjonen ble opprettet."
      },
      {
        mode        = "NULLABLE"
        name        = "oppdatert"
        type        = "TIMESTAMP"
        description = "Når organisasjonen ble sist ble oppdatert."
      },
      {
        mode        = "NULLABLE"
        name        = "oppdatert_av"
        type        = "STRING"
        description = "Unik ID på oppdateringskilden."
      },
    ]
  )

  view_query = <<EOF
SELECT id, orgnummer, navn, opprettet, oppdatert, oppdatert_av
FROM `${var.gcp_project["project"]}.${module.spinnsyn_datastream.dataset_id}.public_organisasjon`
EOF
}

module "spinnsyn_vedtak_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "spinnsyn_vedtak_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "id"
        type        = "STRING"
        description = "Unik ID for vedtaket."
      },
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når vedtaket ble opprettet."
      },
      {
        mode        = "NULLABLE"
        name        = "utbetaling_id"
        type        = "STRING"
        description = "Unik ID på utbetaling tilhørende vedtaket."
      },
    ]
  )

  view_query = <<EOF
SELECT id, opprettet, utbetaling_id
FROM `${var.gcp_project["project"]}.${module.spinnsyn_datastream.dataset_id}.public_vedtak_v2`
EOF
}
