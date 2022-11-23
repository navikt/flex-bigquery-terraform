resource "google_bigquery_table" "bigquery_table" {
  dataset_id = var.dataset_id
  table_id   = var.table_id
  schema     = var.table_schema
}

resource "google_bigquery_table" "bigquery_view" {
  dataset_id = var.dataset_id
  table_id   = var.view_id
  schema     = var.view_schema
  view {
    use_legacy_sql = false
    query          = var.view_query
  }
}

resource "google_bigquery_data_transfer_config" "data_transfer_config" {
  location               = var.location
  destination_dataset_id = var.dataset_id
  display_name           = var.data_transfer_display_name
  data_source_id         = var.data_transfer_data_source_id
  schedule               = var.data_transfer_schedule
  service_account_name   = var.data_transfer_service_account

  schedule_options {
    start_time = var.data_transfer_start_time
  }

  params = {
    destination_table_name_template = var.data_transfer_destination_table
    write_disposition               = var.data_transfer_mode
    query                           = var.data_transfer_query
  }
}