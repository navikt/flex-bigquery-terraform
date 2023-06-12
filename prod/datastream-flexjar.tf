resource "google_bigquery_dataset" "flexjar_datastream" {
  dataset_id = "flexjar_datastream"
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
      table_id   = "flexjar_feedback_spinnsyn_view"
    }
  }
  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "flexjar_feedback_ditt_sykefravaer_fant_du_view"
    }
  }
  timeouts {}
}

resource "google_datastream_connection_profile" "flexjar_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "flexjar-postgresql-connection-profile"
  connection_profile_id = "flexjar-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.flexjar_cloud_sql_port
    username = local.flexjar_datastream_credentials["username"]
    password = local.flexjar_datastream_credentials["password"]
    database = "flexjar-backend-db"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}

resource "google_datastream_stream" "flexjar_datastream" {
  stream_id     = "flexjar-datastream"
  display_name  = "flexjar-datastream"
  desired_state = "RUNNING"
  project       = var.gcp_project["project"]
  location      = var.gcp_project["region"]
  labels        = {}
  backfill_all {}
  timeouts {}

  source_config {
    source_connection_profile = google_datastream_connection_profile.flexjar_postgresql_connection_profile.id

    postgresql_source_config {
      max_concurrent_backfill_tasks = 0
      publication                   = "flexjar_backend_publication"
      replication_slot              = "flexjar_backend_replication"

      exclude_objects {
        postgresql_schemas {
          schema = "public"

          postgresql_tables {
            table = "flyway_schema_history"
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
        dataset_id = "${var.gcp_project["project"]}:${google_bigquery_dataset.flexjar_datastream.dataset_id}"
      }
    }
  }
}
