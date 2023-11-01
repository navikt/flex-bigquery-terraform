resource "google_bigquery_dataset" "modia_kontakt_metrikk_datastream" {
  dataset_id = "modia_kontakt_metrikk_datastream"
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
  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "modia_kontakt_metrikk_henvendelse_view"
    }
  }
  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "modia_sykepengesoknad_kontakt_view"
    }
  }
  timeouts {}
}

resource "google_datastream_connection_profile" "modia_kontakt_metrikk_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "modia-kontakt-metrikk-postgresql-connection-profile"
  connection_profile_id = "modia-kontakt-metrikk-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.modia_kontakt_metrikk_cloud_sql_port
    username = local.modia_kontakt_metrikk_datastream_credentials["username"]
    password = local.modia_kontakt_metrikk_datastream_credentials["password"]
    database = "flex-modia-kontakt-metrikk-db"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}
