data "google_secret_manager_secret_version" "sykepengesoknad_datastream_secret" {
  secret = var.sykepengesoknad_datastream_secret
}

locals {
  sykepengesoknad_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_datastream_secret.secret_data
  )
}

// Datastrean connection profile for PostgreSQL source. Used to create the Datastream.
resource "google_datastream_connection_profile" "sykepengesoknad_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "sykepengesoknad-postgresql-connection-profile"
  connection_profile_id = "sykepengesoknad-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = 5432
    username = local.sykepengesoknad_datastream_credentials["username"]
    password = local.sykepengesoknad_datastream_credentials["password"]
    database = "sykepengesoknad"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}

// Datastream connection profile for BigQuery target.
resource "google_datastream_connection_profile" "sykepengesoknad_bigquery_connection_profile" {
  display_name          = "sykepengesoknad-bigquery-connection-profile"
  location              = var.gcp_project["region"]
  connection_profile_id = "sykepengesoknad-bigquery-connection-profile"

  bigquery_profile {}
}
