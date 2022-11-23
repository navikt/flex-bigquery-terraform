resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.dataset_id
  location   = var.location

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
    user_by_email = var.dataset_iam_member
  }

  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
}