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
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "sykepengesoknad_arkivering_oppgave_gosys_oppgaver_opprettet_view"
      }
    },
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "sykepengesoknad_arkivering_oppgave_gosys_oppgaver_gruppert_view"
      }
    },
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "medlemskap_uavklart_gosys_view"
      }
    }
  ]
}

module "flexjar_datastream" {
  source                            = "../modules/google-bigquery-datastream"
  gcp_project                       = var.gcp_project
  application_name                  = "flexjar"
  cloud_sql_instance_name           = "flexjar-backend"
  cloud_sql_instance_db_name        = "flexjar-backend-db"
  cloud_sql_instance_db_credentials = local.flexjar_datastream_credentials
  datastream_vpc_resources          = local.datastream_vpc_resources

  authorized_views = [
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "flexjar_feedback_view"
      }
    },
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "flexjar_syfooversikt_view"
      }
    }
  ]
}

module "inntektsmelding_status_datastream" {
  source                            = "../modules/google-bigquery-datastream"
  gcp_project                       = var.gcp_project
  application_name                  = "inntektsmelding-status"
  cloud_sql_instance_name           = "flex-inntektsmelding-status"
  cloud_sql_instance_db_name        = "flex-inntektsmelding-status-db"
  cloud_sql_instance_db_credentials = local.inntektsmelding_status_datastream_credentials
  datastream_vpc_resources          = local.datastream_vpc_resources

  authorized_views = [
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "venter_pa_arbeidsgiver_view"
      }
    },
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "varsling_events_view"
      }
    },
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "siste_sis_status_sykepengesoknad"
      }
    }
  ]
}

module "sykepengesoknad_datastream" {
  source                            = "../modules/google-bigquery-datastream"
  gcp_project                       = var.gcp_project
  application_name                  = "sykepengesoknad"
  cloud_sql_instance_name           = "sykepengesoknad"
  cloud_sql_instance_db_name        = "sykepengesoknad"
  cloud_sql_instance_db_credentials = local.sykepengesoknad_datastream_credentials
  datastream_vpc_resources          = local.datastream_vpc_resources

  authorized_views = [
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "sykepengesoknad_sykepengesoknad_view"
      }
    },
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "sykepengesoknad_hovedsporsmal_view"
      }
    },
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "sykepengesoknad_sporsmal_svar_view"
      }
    },
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "sykepengesoknad_andre_inntektskilder_view"
      }
    },
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "sykepengesoknad_klipp_metrikk_view"
      }
    },
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "sykepengesoknad_yrkesskade_sykmelding_view"
      }
    },
    {
      view = {
        dataset_id = "flex_dataset"
        project_id = var.gcp_project["project"]
        table_id   = "medlemskap_uavklart_gosys_view"
      }
    }
  ]
}


