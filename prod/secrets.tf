data "google_secret_manager_secret_version" "spinnsyn_bigquery_secret" {
  secret = "spinnsyn-bigquery-credentials"
}

locals {
  spinnsyn_db = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "spinnsyn_datastream_secret" {
  secret = "spinnsyn-datastream-credentials"
}

locals {
  spinnsyn_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "sykepengesoknad_bigquery_secret" {
  secret = "sykepengesoknad-bigquery-credentials"
}

locals {
  sykepengesoknad_db = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "sykepengesoknad_datastream_secret" {
  secret = "sykepengesoknad-datastream-credentials"
}

locals {
  sykepengesoknad_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "arkivering_oppgave_bigquery_secret" {
  secret = "arkivering-oppgave-bigquery-credentials"
}

locals {
  arkivering_oppgave_db = jsondecode(
    data.google_secret_manager_secret_version.arkivering_oppgave_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "arkivering_oppgave_datastream_secret" {
  secret = "arkivering-oppgave-datastream-credentials"
}

locals {
  arkivering_oppgave_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.arkivering_oppgave_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "sak_status_metrikk_bigquery_secret" {
  secret = "sak-status-metrikk-bigquery-credentials"
}

locals {
  sak_status_metrikk_db = jsondecode(
    data.google_secret_manager_secret_version.sak_status_metrikk_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "sak_status_metrikk_datastream_secret" {
  secret = "sak-status-metrikk-datastream-credentials"
}

locals {
  sak_status_metrikk_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.sak_status_metrikk_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "flexjar_bigquery_secret" {
  secret = "flexjar-bigquery-credentials"
}

locals {
  flexjar_bigquery_credentials = jsondecode(
    data.google_secret_manager_secret_version.flexjar_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "flexjar_datastream_secret" {
  secret = "flexjar-datastream-credentials"
}

locals {
  flexjar_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.flexjar_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "modia_kontakt_metrikk_bigquery_secret" {
  secret = "modia-kontakt-metrikk-bigquery-credentials"
}

locals {
  modia_kontakt_metrikk_bigquery_credentials = jsondecode(
    data.google_secret_manager_secret_version.modia_kontakt_metrikk_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "modia_kontakt_metrikk_datastream_secret" {
  secret = "modia-kontakt-metrikk-datastream-credentials"
}

locals {
  modia_kontakt_metrikk_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.modia_kontakt_metrikk_datastream_secret.secret_data
  )
}