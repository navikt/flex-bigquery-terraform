data "google_secret_manager_secret_version" "sykepengesoknad_sak_status_bigquery_secret" {
  secret = var.sykepengesoknad_sak_status_bigquery_secret
}

locals {
  sak_status_metrikk_db = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_sak_status_bigquery_secret.secret_data
  )
}

module "sykepengesoknad_sak-status-metrikk-bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-sak-status-metrikk"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad-sak-status-metrikk"
  database      = "sykepengesoknad-sak-status-metrikk-db"
  username      = local.sak_status_metrikk_db.username
  password      = local.sak_status_metrikk_db.password
}