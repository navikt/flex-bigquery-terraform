module "spinnsyn_test_view" {
  source = "../modules/google-bigquery-view"

  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "spinnsyn_test_view"
  deletion_protection = false
  view_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "opprettet"
        type = "TIMESTAMP"
      },
    ]
  )

  view_query = <<EOF
SELECT id, opprettet
FROM `${var.gcp_project["project"]}.${module.spinnsyn_datastream.dataset_id}.public_vedtak_v2`
EOF
}