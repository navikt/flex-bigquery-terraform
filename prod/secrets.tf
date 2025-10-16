data "google_secret_manager_secret_version" "spinnsyn_bigquery_secret" {
  secret  = "spinnsyn-bigquery-credentials"
  version = "2"
}

locals {
  spinnsyn_bigquery_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "spinnsyn_datastream_secret" {
  secret  = "spinnsyn-datastream-credentials"
  version = "5"
}

locals {
  spinnsyn_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "sykepengesoknad_bigquery_secret" {
  secret  = "sykepengesoknad-bigquery-credentials"
  version = "2"
}

locals {
  sykepengesoknad_bigquery_credentials = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "sykepengesoknad_datastream_secret" {
  secret  = "sykepengesoknad-datastream-credentials"
  version = "4"
}

locals {
  sykepengesoknad_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "arkivering_oppgave_bigquery_secret" {
  secret  = "arkivering-oppgave-bigquery-credentials"
  version = "3"
}

locals {
  arkivering_oppgave_bigquery_credentials = jsondecode(
    data.google_secret_manager_secret_version.arkivering_oppgave_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "arkivering_oppgave_datastream_secret" {
  secret  = "arkivering-oppgave-datastream-credentials"
  version = "3"
}

locals {
  arkivering_oppgave_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.arkivering_oppgave_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "flexjar_bigquery_secret" {
  secret  = "flexjar-bigquery-credentials"
  version = "2"
}

locals {
  flexjar_bigquery_credentials = jsondecode(
    data.google_secret_manager_secret_version.flexjar_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "flexjar_datastream_secret" {
  secret  = "flexjar-datastream-credentials"
  version = "2"
}

locals {
  flexjar_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.flexjar_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "inntektsmelding_status_bigquery_secret" {
  secret  = "inntektsmelding-status-bigquery-credentials"
  version = "3"
}

locals {
  inntektsmelding_status_bigquery_credentials = jsondecode(
    data.google_secret_manager_secret_version.inntektsmelding_status_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "inntektsmelding_status_datastream_secret" {
  secret  = "inntektsmelding-status-datastream-credentials"
  version = "2"
}

locals {
  inntektsmelding_status_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.inntektsmelding_status_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "spinnsyn_arkivering_bigquery_secret" {
  secret  = "spinnsyn-arkivering-bigquery-credentials"
  version = "2"
}

locals {
  spinnsyn_arkivering_bigquery_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_arkivering_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "spinnsyn_arkivering_datastream_secret" {
  secret  = "spinnsyn-arkivering-datastream-credentials"
  version = "2"
}

locals {
  spinnsyn_arkivering_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_arkivering_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "flex_arbeidssokerregister_oppdatering_datastream_secret" {
  secret  = "flex-arbeidssokerregister-oppdatering-datastream-credentials"
  version = "1"
}

locals {
  flex_arbeidssokerregister_oppdatering_credentials = jsondecode(
    data.google_secret_manager_secret_version.flex_arbeidssokerregister_oppdatering_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "flex_sykmeldinger_backend_datastream_credentials_secret" {
  secret  = "flex-sykmeldinger-backend-datastream-credentials"
  version = "3"
}

locals {
  flex_sykmeldinger_datastream_backend_credentials = jsondecode(
    data.google_secret_manager_secret_version.flex_sykmeldinger_backend_datastream_credentials_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "flex_sykmeldinger_backend_bigquery_secret" {
  secret  = "flex-sykmeldinger-backend-bigquery-credentials"
  version = "4"
}

locals {
  flex_sykmeldinger_backend_bigquery_credentials = jsondecode(
    data.google_secret_manager_secret_version.flex_sykmeldinger_backend_bigquery_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "slack_app_access_token" {
  secret  = "slack_app_access_token"
  version = "latest"
}

locals {
  slack_app_access_token = data.google_secret_manager_secret_version.slack_app_access_token.secret_data
}
