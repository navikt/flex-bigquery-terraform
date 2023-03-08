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
    role          = "roles/bigquery.dataViewer"
    user_by_email = var.metabase_service_account
  }
  timeouts {}
}

resource "google_datastream_connection_profile" "sak_status_metrikk_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "sak-status-metrikk-postgresql-connection-profile"
  connection_profile_id = "sak-status-metrikk-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.sak_status_metrikk_cloud_sql_port
    username = local.sak_status_metrikk_datastream_credentials["username"]
    password = local.sak_status_metrikk_datastream_credentials["password"]
    database = "sykepengesoknad-sak-status-metrikk-db"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}

resource "google_datastream_stream" "sak_status_metrikk_datastream" {
  stream_id     = "sak-status-metrikk-datastream"
  display_name  = "sak-status-metrikk-datastream"
  desired_state = "RUNNING"
  project       = var.gcp_project["project"]
  location      = var.gcp_project["region"]
  labels        = {}
  backfill_all {}
  timeouts {}

  source_config {
    source_connection_profile = google_datastream_connection_profile.sak_status_metrikk_postgresql_connection_profile.id

    postgresql_source_config {
      max_concurrent_backfill_tasks = 0
      publication                   = "sak_status_metrikk_publication"
      replication_slot              = "sak_status_metrikk_replication"

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
        dataset_id = "${var.gcp_project["project"]}:${google_bigquery_dataset.sak_status_metrikk_datastream.dataset_id}"
      }
    }
  }
}
