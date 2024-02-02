module "soda_sendt_sykepengesoknad_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "soda-sendt-sykepengesoknad-avstemming-view"
  view_schema = jsonencode(
    [
      {
        name = "sykepengesoknad_uuid"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT sykepengesoknad_uuid
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.sykepengesoknad_sykepengesoknad_view`
WHERE status = 'SENDT'
  AND sendt < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 HOUR)
  AND sendt >= TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY), INTERVAL -7 DAY)
  AND sykepengesoknad_uuid NOT IN (
    SELECT sykepengesoknad_id FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.sykepengesoknad_arkivering_oppgave_innsending_view`
    WHERE behandlet >= TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY), INTERVAL -7 DAY)
  )
EOF

}