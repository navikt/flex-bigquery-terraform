resource "google_bigquery_dataset" "flex_dataset" {
  dataset_id    = "flex_dataset"
  location      = var.gcp_project["region"]
  friendly_name = "flex_dataset"
  labels        = {}

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
    role          = "WRITER"
    user_by_email = var.hotjar_service_account
  }
  access {
    role          = "roles/bigquery.metadataViewer"
    user_by_email = var.metabase_service_account
  }
  access {
    role           = "roles/bigquery.metadataViewer"
    group_by_email = "all-users@nav.no"
  }
  access {
    view {
      dataset_id = "flex_dataset"
      project_id = var.gcp_project["project"]
      table_id   = "sykepengesoknad_hovedsporsmal_pivot_view"
    }
  }
  timeouts {}
}

resource "google_bigquery_table_iam_binding" "sykepengesoknad_view_iam_binding" {
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.sykepengesoknad_sykepengesoknad_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_table_iam_binding" "sykepengesoknad_hovedsporsmal_pivot_view_iam_binding" {
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.sykepengesoknad_hovedsporsmal_pivot_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_table_iam_binding" "sykepengesoknad_klipp_metrikk_view_iam_binding" {
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.sykepengesoknad_klipp_metrikk_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_table_iam_binding" "sykepengesoknad_andre_inntektskilder_view_iam_binding" {
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.sykepengesoknad_andre_inntektskilder_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_table_iam_binding" "korrigerte_sporsmal_tilstand_view_iam_binding" {
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.korrigerte_sporsmal_tilstand_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_table_iam_binding" "sykepengesoknad_sak_status_metrikk_tilstand_view_iam_binding" {
  depends_on = [module.sykepengesoknad_sak_status_metrikk_tilstand_view]
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.sykepengesoknad_sak_status_metrikk_tilstand_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_table_iam_binding" "sykepengesoknad_sak_status_metrikk_siste_tilstand_view_iam_binding" {
  depends_on = [module.sykepengesoknad_sak_status_metrikk_siste_tilstand_view]
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.sykepengesoknad_sak_status_metrikk_siste_tilstand_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
  ]
}

module "spinnsyn_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "spinnsyn-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:spinnsyn-backend"
  database      = "spinnsyn-db"
  username      = local.spinnsyn_db.username
  password      = local.spinnsyn_db.password
}

module "sykepengesoknad_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad"
  database      = "sykepengesoknad"
  username      = local.sykepengesoknad_db.username
  password      = local.sykepengesoknad_db.password
}

module "sykepengesoknad_arkivering_oppgave_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-arkivering-oppgave"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad-arkivering-oppgave"
  database      = "sykepengesoknad-arkivering-oppgave-db"
  username      = local.arkivering_oppgave_db.username
  password      = local.arkivering_oppgave_db.password
}

module "sykepengesoknad_sak_status_metrikk_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-sak-status-metrikk"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad-sak-status-metrikk"
  database      = "sykepengesoknad-sak-status-metrikk-db"
  username      = local.sak_status_metrikk_db.username
  password      = local.sak_status_metrikk_db.password
}