data "google_secret_manager_secret_version" "spinnsyn_datastream_secret" {
  secret = "spinnsyn-datastream-credentials"
}

locals {
  spinnsyn_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinnsyn_datastream_secret.secret_data
  )
}

data "google_secret_manager_secret_version" "flex_datastream_test_secret" {
  secret = "flex-datastream-test-credentials"
}

locals {
  flex_datastream_test_credentials = jsondecode(
    data.google_secret_manager_secret_version.flex_datastream_test_secret.secret_data
  )
}
