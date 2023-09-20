resource "google_bigquery_dataset" "sykepengesoknad_datastream" {
  dataset_id = "sykepengesoknad_datastream"
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
      table_id   = "sykepengesoknad_sykepengesoknad_view"
    }
  }
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
      table_id   = "sykepengesoknad_sporsmal_svar_view"
    }
  }
  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "sykepengesoknad_andre_inntektskilder_view"
    }
  }
  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "sykepengesoknad_klipp_metrikk_view"
    }
  }
  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "sykepengesoknad_yrkesskade_sykmelding_view"
    }
  }
  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "modia_sykepengesoknad_kontakt_view"
    }
  }
  timeouts {}
}

resource "google_datastream_connection_profile" "sykepengesoknad_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "sykepengesoknad-postgresql-connection-profile"
  connection_profile_id = "sykepengesoknad-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = 5432
    username = local.sykepengesoknad_datastream_credentials["username"]
    password = local.sykepengesoknad_datastream_credentials["password"]
    database = "sykepengesoknad"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}

resource "google_datastream_stream" "sykepengesoknad_datastream" {
  stream_id     = "sykepengesoknad-datastream"
  display_name  = "sykepengesoknad-datastream"
  desired_state = "RUNNING"
  project       = var.gcp_project["project"]
  location      = var.gcp_project["region"]
  labels        = {}
  backfill_all {}
  timeouts {}

  source_config {
    source_connection_profile = google_datastream_connection_profile.sykepengesoknad_postgresql_connection_profile.id

    postgresql_source_config {
      max_concurrent_backfill_tasks = 0
      publication                   = "sykepengesoknad_publication"
      replication_slot              = "sykepengesoknad_replication"

      exclude_objects {
        postgresql_schemas {
          schema = "public"

          postgresql_tables {
            table = "flyway_schema_history"
          }
          postgresql_tables {
            table = "sykepengesoknad"
          }
        }
      }

      include_objects {
        postgresql_schemas {
          schema = "public"
        }
      }
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.datastream_bigquery_connection_profile.id

    bigquery_destination_config {
      data_freshness = "900s"

      single_target_dataset {
        dataset_id = "${var.gcp_project["project"]}:${google_bigquery_dataset.sykepengesoknad_datastream.dataset_id}"
      }
    }
  }
}