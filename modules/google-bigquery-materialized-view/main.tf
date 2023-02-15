resource "google_bigquery_table" "view" {
  dataset_id          = var.dataset_id
  table_id            = var.view_id
  deletion_protection = var.deletion_protection

  materialized_view {
    query = var.view_query
  }
}
