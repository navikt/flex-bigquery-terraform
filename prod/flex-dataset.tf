resource "google_bigquery_dataset" "flex_dataset" {
  dataset_id    = "flex_dataset"
  location      = var.gcp_project["region"]
  friendly_name = "flex_dataset"

  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "sykepengesoknad_hovedsporsmal_view"
    }
  }

  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "sykepengesoknad_sykepengesoknad_view"
    }
  }

  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "sykepengesoknad_arkivering_oppgave_oppgavestyring_view"
    }
  }

  access {
    group_by_email = "all-users@nav.no"
    role           = "roles/bigquery.metadataViewer"
  }
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role          = "WRITER"
    user_by_email = "flex-hotjar-flex-uu7nyvy@nais-prod-020f.iam.gserviceaccount.com"
  }
  access {
    role          = "WRITER"
    user_by_email = "service-1002409980618@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
  }
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
  access {
    role          = "roles/bigquery.metadataViewer"
    user_by_email = "nada-metabase@nada-prod-6977.iam.gserviceaccount.com"
  }
}