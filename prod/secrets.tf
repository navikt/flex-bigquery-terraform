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

data "google_secret_manager_secret_version" "sak_status_metrikk_bigquery_secret" {
  secret = var.sak_status_metrikk_bigquery_secret
}

locals {
  sak_status_metrikk_db = jsondecode(
    data.google_secret_manager_secret_version.sak_status_metrikk_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "sak_status_metrikk_datastream_secret" {
  secret = var.sak_status_metrikk_datastream_secret
}

locals {
  sak_status_metrikk_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.sak_status_metrikk_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "flexjar_datastream_secret" {
  secret = var.flexjar_datastream_secret
}

locals {
  flexjar_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.flexjar_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "modia_kontakt_metrikk_datastream_secret" {
  secret = var.modia_kontakt_metrikk_datastream_secret
}

locals {
  modia_kontakt_metrikk_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.modia_kontakt_metrikk_datastream_secret.secret_data
  )
}