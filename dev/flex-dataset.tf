resource "google_bigquery_dataset" "flex_dataset" {
  dataset_id    = "flex_dataset"
  location      = var.gcp_project["region"]
  friendly_name = "flex_dataset"
  labels        = {}

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

module "spinnsyn_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "spinnsyn-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:spinnsyn-backend"
  database      = "spinnsyn-db"
  username      = local.spinnsyn_db.username
  password      = local.spinnsyn_db.password
}

module "sykepengesoknad_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad"
  database      = "sykepengesoknad"
  username      = local.sykepengesoknad_db.username
  password      = local.sykepengesoknad_db.password
}

module "sykepengesoknad_arkivering_oppgave_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-arkivering-oppgave"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad-arkivering-oppgave"
  database      = "sykepengesoknad-arkivering-oppgave-db"
  username      = local.arkivering_oppgave_db.username
  password      = local.arkivering_oppgave_db.password
}

module "sykepengesoknad_sak_status_metrikk_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-sak-status-metrikk"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad-sak-status-metrikk"
  database      = "sykepengesoknad-sak-status-metrikk-db"
  username      = local.sak_status_metrikk_db.username
  password      = local.sak_status_metrikk_db.password
}