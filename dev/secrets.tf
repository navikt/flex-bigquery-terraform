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

data "google_secret_manager_secret_version" "flex_arbeidssokerregister_oppdatering_datastream_secret" {
  secret  = "flex-arbeidssokerregister-oppdatering-datastream-credentials"
  version = "1"
}

locals {
  flex_arbeidssokerregister_oppdatering_credentials = jsondecode(
    data.google_secret_manager_secret_version.flex_arbeidssokerregister_oppdatering_datastream_secret.secret_data
  )
}


data "google_secret_manager_secret_version" "flex_sykmeldinger_datastream_credentials_secret" {
  secret  = "flex_sykmeldinger_datastream_credentials"
  version = "1"
}

locals {
  flex_sykmeldinger_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.flex_sykmeldinger_datastream_credentials_secret.secret_data
  )
}
