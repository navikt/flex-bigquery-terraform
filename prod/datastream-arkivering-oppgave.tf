resource "google_bigquery_dataset" "arkivering_oppgave_datastream" {
  dataset_id = "arkivering_oppgave_datastream"
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

data "google_secret_manager_secret_version" "arkivering_oppgave_datastream_secret" {
  secret = var.arkivering_oppgave_datastream_secret
}

locals {
  arkivering_oppgave_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.arkivering_oppgave_datastream_secret.secret_data
  )
}

// Datastrean connection profile for PostgreSQL source. Used to create the Datastream.
resource "google_datastream_connection_profile" "arkivering_oppgave_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "arkivering-oppgave-postgresql-connection-profile"
  connection_profile_id = "arkivering-oppgave-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.arkivering_oppgave_cloud_sql_port
    username = local.arkivering_oppgave_datastream_credentials["username"]
    password = local.arkivering_oppgave_datastream_credentials["password"]
    database = "sykepengesoknad-arkivering-oppgave-db"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}