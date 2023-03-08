resource "google_bigquery_dataset" "spinnsyn_datastream" {
  dataset_id = "spinnsyn_datastream"
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
    role          = "roles/bigquery.dataViewer"
    user_by_email = var.metabase_service_account
  }
  timeouts {}
}

resource "google_datastream_connection_profile" "spinnsyn_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "spinnsyn-postgresql-connection-profile"
  connection_profile_id = "spinnsyn-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.spinnsyn_cloud_sql_port
    username = local.spinnsyn_datastream_credentials["username"]
    password = local.spinnsyn_datastream_credentials["password"]
    database = "spinnsyn-db"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}

resource "google_datastream_stream" "spinnsyn_datastream" {
  stream_id     = "spinnsyn-datastream"
  display_name  = "spinnsyn-datastream"
  desired_state = "RUNNING"
  project       = var.gcp_project["project"]
  location      = var.gcp_project["region"]
  labels        = {}
  backfill_all {}
  timeouts {}

  source_config {
    source_connection_profile = google_datastream_connection_profile.spinnsyn_postgresql_connection_profile.id

    postgresql_source_config {
      max_concurrent_backfill_tasks = 0
      publication                   = "spinnsyn_backend_publication"
      replication_slot              = "spinnsyn_backend_replication"

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
        dataset_id = "${var.gcp_project["project"]}:${google_bigquery_dataset.spinnsyn_datastream.dataset_id}"
      }
    }
  }
}
