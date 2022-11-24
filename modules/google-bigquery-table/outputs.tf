
output "bigquery_table_id" {
  description = "The name of the created table"
  value       = google_bigquery_table.bigquery_table.table_id
}

output "bigquery_view_id" {
  description = "The name of the created view"
  value       = google_bigquery_table.bigquery_view.table_id
}
