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
    role           = "READER"
    group_by_email = "all-users@nav.no"
  }
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
  access {
    role          = "roles/bigquery.metadataViewer"
    user_by_email = var.metabase_service_account
  }
  access {
    role          = "READER"
    user_by_email = "terraform@tbd-prod-eacd.iam.gserviceaccount.com"
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

resource "google_bigquery_table_iam_binding" "sykepengesoknad_yrkesskade_sykmelding_view_iam_binding" {
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.sykepengesoknad_yrkesskade_sykmelding_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_table_iam_binding" "flexjar_feedback_view_iam_binding" {
  depends_on = [module.flexjar_feedback_view]
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.flexjar_feedback_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
    "serviceAccount:syfo-71ci@knada-gcp.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_table_iam_binding" "flexjar_syfooversikt_view_iam_binding" {
  depends_on = [module.flexjar_syfooversikt_view]
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.flexjar_syfooversikt_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "serviceAccount:syfo-71ci@knada-gcp.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_table_iam_binding" "spinnsyn_utbetaling_view_iam_binding" {
  depends_on = [module.spinnsyn_utbetaling_view]
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.spinnsyn_utbetaling_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_table_iam_binding" "venter_pa_arbeidsgiver_view_iam_binding" {
  depends_on = [module.venter_pa_arbeidsgiver_view]
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.venter_pa_arbeidsgiver_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_table_iam_binding" "varsling_events_view_iam_binding" {
  depends_on = [module.varsling_events_view]
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = module.varsling_events_view.bigquery_view_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "group:all-users@nav.no",
    "serviceAccount:nada-metabase@nada-prod-6977.iam.gserviceaccount.com",
  ]
}
