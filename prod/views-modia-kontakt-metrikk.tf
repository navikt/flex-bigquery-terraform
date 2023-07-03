module "modia_kontakt_metrikk_henvendelse_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "modia_kontakt_metrikk_henvendelse_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "id"
        type        = "STRING"
        description = "Unik ID for henvendelsen."
      },
      {
        mode        = "NULLABLE"
        name        = "tema"
        type        = "STRING"
        description = "Hva henvendelsen gjelder."
      },
      {
        mode        = "NULLABLE"
        name        = "temagruppe"
        type        = "STRING"
        description = "Hvilken type henvendelse det er."
      },
      {
        mode        = "NULLABLE"
        name        = "traad_id"
        type        = "STRING"
        description = "Id på samtalen henvendelsen tilhører."
      },
      {
        mode        = "NULLABLE"
        name        = "tidspunkt"
        type        = "TIMESTAMP"
        description = "Tidspunkt for henvendelsen."
      },
    ]
  )
  view_query = <<EOF
SELECT id, tema, temagruppe, traad_id, tidspunkt
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.modia_kontakt_metrikk_datastream.dataset_id}.public_henvendelse`
EOF

}