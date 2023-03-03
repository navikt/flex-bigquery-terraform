data "google_secret_manager_secret_version" "spinnsyn_datastream_secret" {
  secret = var.spinnsyn_datastream_secret
}

locals {
  spinnsyn_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_datastream_secret.secret_data
  )
}

// Datastrean connection profile for PostgreSQL source. Used to create the Datastream.
resource "google_datastream_connection_profile" "spinnsyn_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "spinnsyn-postgresql-connection-profile"
  connection_profile_id = "spinnsyn-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.spinnsyn_cloud_sql_port
    username = local.spinnsyn_datastream_credentials["username"]
    password = local.spinnsyn_datastream_credentials["password"]
    database = "spinnsyn-db"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}

// Datastream connection profile for BigQuery target.
resource "google_datastream_connection_profile" "spinnsyn_bigquery_connection_profile" {
  display_name          = "spinnsyn-bigquery-connection-profile"
  location              = var.gcp_project["region"]
  connection_profile_id = "spinnsyn-bigquery-connection-profile"

  bigquery_profile {}
}
