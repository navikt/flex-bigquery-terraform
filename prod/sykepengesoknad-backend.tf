data "google_secret_manager_secret_version" "sykepengesoknad_bigquery_secret" {
  secret = var.sykepengesoknad_bigquery_secret
}

locals {
  sykepengesoknad_db = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_bigquery_secret.secret_data
  )
}

module "sykepengesoknad_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad-backend"
  database      = "sykepengesoknad"
  username      = local.sykepengesoknad_db.username
  password      = local.sykepengesoknad_db.password
}
