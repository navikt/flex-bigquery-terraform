resource "google_bigquery_dataset" "flex_datastream_test_datastream" {
  dataset_id = "flex_datastream_test_datastream"
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
  timeouts {}
}

resource "google_datastream_connection_profile" "flex_datastream_test_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "flex-datastream-test-postgresql-connection-profile"
  connection_profile_id = "flex-datastream-test-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.cloud_sql_auth_proxy_compute_instance.network_interface[0].network_ip
    port     = var.flex_datastream_test_cloud_sql_port
    username = local.flex_datastream_test_credentials["username"]
    password = local.flex_datastream_test_credentials["password"]
    database = "flex-datastream-test-db"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}

resource "google_datastream_stream" "flex_datastream_test_datastream" {
  depends_on = [
    google_datastream_connection_profile.flex_datastream_test_postgresql_connection_profile,
    google_datastream_connection_profile.datastream_bigquery_connection_profile,
    google_bigquery_dataset.flex_datastream_test_datastream
  ]
  stream_id     = "flex-datastream-test-datastream"
  display_name  = "flex-datastream-test-datastream"
  desired_state = "RUNNING"
  project       = var.gcp_project["project"]
  location      = var.gcp_project["region"]
  labels        = {}
  backfill_all {}
  timeouts {}

  source_config {
    source_connection_profile = google_datastream_connection_profile.flex_datastream_test_postgresql_connection_profile.id

    postgresql_source_config {
      max_concurrent_backfill_tasks = 0
      publication                   = "flex_datastream_test_publication"
      replication_slot              = "flex_datastream_test_replication"

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
        dataset_id = "${var.gcp_project["project"]}:${google_bigquery_dataset.flex_datastream_test_datastream.dataset_id}"
      }
    }
  }
}
