resource "google_bigquery_dataset" "sykepengesoknad_datastream" {
  dataset_id = "sykepengesoknad_datastream"
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

data "google_secret_manager_secret_version" "sykepengesoknad_datastream_secret" {
  secret = var.sykepengesoknad_datastream_secret
}

locals {
  sykepengesoknad_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_datastream_secret.secret_data
  )
}

resource "google_datastream_connection_profile" "sykepengesoknad_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "sykepengesoknad-postgresql-connection-profile"
  connection_profile_id = "sykepengesoknad-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.sykepengesoknad_cloud_sql_port
    username = local.sykepengesoknad_datastream_credentials["username"]
    password = local.sykepengesoknad_datastream_credentials["password"]
    database = "sykepengesoknad"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}