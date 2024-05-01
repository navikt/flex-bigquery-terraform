data "google_secret_manager_secret_version" "spinnsyn_datastream_secret" {
  secret = var.spinnsyn_datastream_secret
}

locals {
  spinnsyn_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_datastream_secret.secret_data
  )
}

