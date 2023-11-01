resource "google_bigquery_dataset" "modia_kontakt_metrikk_datastream" {
  dataset_id = "modia_kontakt_metrikk_datastream"
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
      table_id   = "modia_kontakt_metrikk_henvendelse_view"
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

resource "google_datastream_connection_profile" "modia_kontakt_metrikk_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "modia-kontakt-metrikk-postgresql-connection-profile"
  connection_profile_id = "modia-kontakt-metrikk-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.flex_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.modia_kontakt_metrikk_cloud_sql_port
    username = local.modia_kontakt_metrikk_datastream_credentials["username"]
    password = local.modia_kontakt_metrikk_datastream_credentials["password"]
    database = "flex-modia-kontakt-metrikk-db"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.flex_datastream_private_connection.id
  }
}

resource "google_datastream_stream" "modia_kontakt_metrikk_datastream" {
  depends_on    = [google_datastream_connection_profile.modia_kontakt_metrikk_postgresql_connection_profile]
  stream_id     = "modia-kontakt-metrikk-datastream"
  display_name  = "modia-kontakt-metrikk-datastream"
  desired_state = "RUNNING"
  project       = var.gcp_project["project"]
  location      = var.gcp_project["region"]
  labels        = {}
  backfill_all {}
  timeouts {}

  source_config {
    source_connection_profile = google_datastream_connection_profile.modia_kontakt_metrikk_postgresql_connection_profile.id

    postgresql_source_config {
      max_concurrent_backfill_tasks = 0
      publication                   = "flex_modia_kontakt_metrikk_publication"
      replication_slot              = "flex_modia_kontakt_metrikk_replication"

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
        dataset_id = "${var.gcp_project["project"]}:${google_bigquery_dataset.modia_kontakt_metrikk_datastream.dataset_id}"
      }
    }
  }
}
