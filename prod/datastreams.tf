locals {
  datastream_vpc_resources = {
    vpc_name                       = google_compute_network.flex_datastream_private_vpc.name
    private_connection_id          = google_datastream_private_connection.flex_datastream_private_connection.id
    bigquery_connection_profile_id = google_datastream_connection_profile.datastream_bigquery_connection_profile.id
  }
}

module "spinnsyn_datastream" {
  source                            = "../modules/google-bigquery-datastream"
  gcp_project                       = var.gcp_project
  application_name                  = "spinnsyn"
  cloud_sql_instance_name           = "spinnsyn-backend"
  cloud_sql_instance_db_name        = "spinnsyn-db"
  cloud_sql_instance_db_credentials = local.spinnsyn_datastream_credentials
  datastream_vpc_resources          = local.datastream_vpc_resources

  authorized_views = [
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "spinnsyn_utbetaling_view"
      }
    }
  ]
}

module "arkivering_oppgave_datastream" {
  source                            = "../modules/google-bigquery-datastream"
  gcp_project                       = var.gcp_project
  application_name                  = "arkivering-oppgave"
  cloud_sql_instance_name           = "sykepengesoknad-arkivering-oppgave"
  cloud_sql_instance_db_name        = "sykepengesoknad-arkivering-oppgave-db"
  cloud_sql_instance_db_credentials = local.arkivering_oppgave_datastream_credentials
  datastream_vpc_resources          = local.datastream_vpc_resources

  authorized_views = [
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "sykepengesoknad_arkivering_oppgave_oppgavestyring_view"
      }
    },
    { view = {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "sykepengesoknad_arkivering_oppgave_gosys_oppgaver_opprettet_view"
    } },
    { view = {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "sykepengesoknad_arkivering_oppgave_gosys_oppgaver_gruppert_view"
    } }
  ]
}