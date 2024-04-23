data "google_secret_manager_secret_version" "spinnsyn_bigquery_secret" {
  secret = var.spinnsyn_bigquery_secret
}

locals {
  spinnsyn_db = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "spinnsyn_datastream_secret" {
  secret = var.spinnsyn_datastream_secret
}

locals {
  spinnsyn_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "sykepengesoknad_bigquery_secret" {
  secret = var.sykepengesoknad_bigquery_secret
}

locals {
  sykepengesoknad_db = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "sykepengesoknad_datastream_secret" {
  secret = var.sykepengesoknad_datastream_secret
}

locals {
  sykepengesoknad_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "arkivering_oppgave_bigquery_secret" {
  secret = var.arkivering_oppgave_bigquery_secret
}

locals {
  arkivering_oppgave_db = jsondecode(
    data.google_secret_manager_secret_version.arkivering_oppgave_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "arkivering_oppgave_datastream_secret" {
  secret = var.arkivering_oppgave_datastream_secret
}

locals {
  arkivering_oppgave_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.arkivering_oppgave_datastream_secret.secret_data
  )
}
