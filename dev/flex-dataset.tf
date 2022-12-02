resource "google_bigquery_dataset" "flex_dataset" {
  dataset_id    = "flex_dataset"
  location      = var.gcp_project["region"]
  friendly_name = "flex_dataset"

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
    user_by_email = "flex-hotjar-flex-uu7nyvy@nais-dev-2e7b.iam.gserviceaccount.com"
  }
  access {
    role          = "WRITER"
    user_by_email = "service-621342450460@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
  }
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
}