resource "google_bigquery_dataset" "sak_status_metrikk_datastream" {
  dataset_id = "sak_status_metrikk_datastream"
  location   = var.gcp_project["region"]
  project    = var.gcp_project["project"]
  labels     = {}

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
  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "sykepengesoknad_sak_status_metrikk_siste_tilstand_view"
    }
  }
  timeouts {}
}

