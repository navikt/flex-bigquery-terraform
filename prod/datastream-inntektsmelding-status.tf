resource "google_bigquery_dataset" "inntektsmelding_status_datastream" {
  dataset_id = "inntektsmelding_status_datastream"
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

resource "google_datastream_connection_profile" "inntektsmelding_status_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "inntektsmelding-status-postgresql-connection-profile"
  connection_profile_id = "inntektsmelding-status-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.inntektsmelding_status_cloud_sql_port
    username = local.inntektsmelding_status_datastream_credentials["username"]
    password = local.inntektsmelding_status_datastream_credentials["password"]
    database = "flex-inntektsmelding-status-db"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}
