
output "bigquery_table_id" {
  description = "The name of the created table"
  value       = google_bigquery_table.bigquery_table.table_id
}