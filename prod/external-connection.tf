module "spinnsyn_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "spinnsyn-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:spinnsyn-backend"
  database      = "spinnsyn-db"
  username      = local.spinnsyn_bigquery_credentials.username
  password      = local.spinnsyn_bigquery_credentials.password
}

module "sykepengesoknad_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad"
  database      = "sykepengesoknad"
  username      = local.sykepengesoknad_bigquery_credentials.username
  password      = local.sykepengesoknad_bigquery_credentials.password
}

module "sykmeldinger_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "flex-sykmeldinger-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:flex-sykmeldinger-backend"
  database      = "flex-sykmeldinger-backend-db"
  username      = local.flex_sykmeldinger_backend_bigquery_credentials.username
  password      = local.flex_sykmeldinger_backend_bigquery_credentials.password
}

module "sykepengesoknad_arkivering_oppgave_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-arkivering-oppgave"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad-arkivering-oppgave"
  database      = "sykepengesoknad-arkivering-oppgave-db"
  username      = local.arkivering_oppgave_bigquery_credentials.username
  password      = local.arkivering_oppgave_bigquery_credentials.password
}

module "flexjar_backend_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "flexjar-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:flexjar-backend"
  database      = "flexjar-backend-db"
  username      = local.flexjar_bigquery_credentials.username
  password      = local.flexjar_bigquery_credentials.password
}

module "flex_inntektsmelding_status_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "flex-inntektsmelding-status"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:flex-inntektsmelding-status"
  database      = "flex-inntektsmelding-status-db"
  username      = local.inntektsmelding_status_bigquery_credentials.username
  password      = local.inntektsmelding_status_bigquery_credentials.password
}

module "spinnsyn_arkivering_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "spinnsyn-arkivering"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:spinnsyn-arkivering"
  database      = "spinnsyn-arkivering-db"
  username      = local.spinnsyn_arkivering_bigquery_credentials.username
  password      = local.spinnsyn_arkivering_bigquery_credentials.password
}