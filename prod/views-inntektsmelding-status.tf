module "inntektsmelding_status_event_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "inntektsmelding_status_event_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Tidspunkt for eventet."
      },
      {
        mode        = "NULLABLE"
        name        = "status"
        type        = "STRING"
        description = "status på eventet"
      }
    ]
  )
  view_query = <<EOF
SELECT opprettet, status
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.inntektsmelding_status_datastream.dataset_id}.public_inntektsmelding_status`
EOF

}
