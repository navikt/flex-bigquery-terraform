resource "google_bigquery_dataset" "sak_status_metrikk_datastream" {
  dataset_id = "sak_status_metrikk_datastream"
  location   = var.gcp_project["region"]
  project    = var.gcp_project["project"]
  labels     = {}

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }

  timeouts {}
}

resource "google_datastream_connection_profile" "sak_status_metrikk_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "sak-status-metrikk-postgresql-connection-profile"
  connection_profile_id = "sak-status-metrikk-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.sak_status_metrikk_cloud_sql_port
    username = local.sak_status_metrikk_datastream_credentials["username"]
    password = local.sak_status_metrikk_datastream_credentials["password"]
    database = "sykepengesoknad-sak-status-metrikk-db"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}