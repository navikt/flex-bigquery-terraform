data "google_secret_manager_secret_version" "spinnsyn_datastream_secret" {
  secret  = "spinnsyn-datastream-credentials"
  version = "2"
}

locals {
  spinnsyn_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "spinnsyn_arkivering_datastream_secret" {
  secret  = "spinnsyn-arkivering-datastream-credentials"
  version = "3"
}

locals {
  spinnsyn_arkivering_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_arkivering_datastream_secret.secret_data
  )
}