output "bigquery_view_id" {
  description = "The name of the created view"
  value       = google_bigquery_table.bigquery_view.table_id
}
