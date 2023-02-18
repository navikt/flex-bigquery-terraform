resource "google_compute_network" "flex_datastream_private_vpc" {
  name    = "flex-datastream-vpc"
  project = var.gcp_project["project"]
}

data "google_sql_database_instance" "sykepengesoknad_db" {
  name = "sykepengesoknad"
}

data "google_secret_manager_secret_version" "sykepengesoknad_datastream_secret" {
  secret = var.sykepengesoknad_datastream_secret
}

locals {
  sykepengesoknad_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_datastream_secret.secret_data
  )
}
