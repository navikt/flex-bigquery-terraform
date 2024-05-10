data "google_secret_manager_secret_version" "spinnsyn_datastream_secret" {
  secret = "spinnsyn-datastream-credentials"
}

locals {
  spinnsyn_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_datastream_secret.secret_data
  )
}