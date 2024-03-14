resource "google_bigquery_dataset" "inntektsmelding_status_datastream" {
  dataset_id = "inntektsmelding_status_datastream"
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

resource "google_datastream_connection_profile" "inntektsmelding_status_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "inntektsmelding-status-postgresql-connection-profile"
  connection_profile_id = "inntektsmelding-status-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.inntektsmelding_status_cloud_sql_port
    username = local.inntektsmelding_status_datastream_credentials["username"]
    password = local.inntektsmelding_status_datastream_credentials["password"]
    database = "flex-inntektsmelding-status-db"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}


resource "google_datastream_stream" "inntektsmelding_status_datastream" {
  stream_id     = "inntektsmelding-status-datastream"
  display_name  = "inntektsmelding-status-datastream"
  desired_state = "RUNNING"
  project       = var.gcp_project["project"]
  location      = var.gcp_project["region"]
  labels        = {}
  backfill_all {}
  timeouts {}

  source_config {
    source_connection_profile = google_datastream_connection_profile.inntektsmelding_status_postgresql_connection_profile.id

    postgresql_source_config {
      max_concurrent_backfill_tasks = 0
      publication                   = "flex_inntektsmelding_status_publication"
      replication_slot              = "flex_inntektsmelding_status_replication"

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
      data_freshness = "3600s"

      single_target_dataset {
        dataset_id = "${var.gcp_project["project"]}:${google_bigquery_dataset.inntektsmelding_status_datastream.dataset_id}"
      }
    }
  }
}
