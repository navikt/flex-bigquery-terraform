module "flexjar_feedback_spinnsyn_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "flexjar_feedback_spinnsyn_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "id"
        type        = "STRING"
        description = "Unik ID for feedback."
      },
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når feedbacken ble gitt"
      },
      {
        mode        = "NULLABLE"
        name        = "feedback_id"
        type        = "STRING"
        description = "Hvilket feedback felt det gjelder."
      },
      {
        mode        = "NULLABLE"
        name        = "svar"
        type        = "STRING"
        description = "Hva som er svart på feedbacken. Enten JA, NEI eller utdypende svar."
      },
      {
        mode        = "NULLABLE"
        name        = "er_refusjon"
        type        = "BOOLEAN"
        description = "Om vedtaket er en refusjon."
      },
      {
        mode        = "NULLABLE"
        name        = "har_avviste_dager"
        type        = "BOOLEAN"
        description = "Om vedtaket har aviste dager."
      },
      {
        mode        = "NULLABLE"
        name        = "er_direkteutbetaling"
        type        = "BOOLEAN"
        description = "Om vedtaket er en direkte utbetaling."
      },
      {
        mode        = "NULLABLE"
        name        = "annullert"
        type        = "BOOLEAN"
        description = "Om vedtaket er annulert."
      },
      {
        mode        = "NULLABLE"
        name        = "revurdert"
        type        = "BOOLEAN"
        description = "Om vedtaket er revurdert."
      },
    ]
  )
  view_query = <<EOF
SELECT
  id,
  opprettet,
  JSON_VALUE(feedback_json, '$.feedbackId') AS feedback_id,
  JSON_VALUE(feedback_json, '$.svar') AS svar,
  CAST(JSON_VALUE(feedback_json, '$.erRefusjon') AS BOOL) AS er_refusjon,
  CAST(JSON_VALUE(feedback_json, '$.harAvvisteDager') AS BOOL) AS har_avviste_dager,
  CAST(JSON_VALUE(feedback_json, '$.erDirekteutbetaling') AS BOOL) AS er_direkteutbetaling,
  CAST(JSON_VALUE(feedback_json, '$.annullert') AS BOOL) AS annullert,
  CAST(JSON_VALUE(feedback_json, '$.revurdert') AS BOOL) AS revurdert
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flexjar_datastream.dataset_id}.public_feedback`
WHERE JSON_VALUE(feedback_json, '$.app') = 'spinnsyn-frontend'
EOF

}

module "flexjar_feedback_ditt_sykefravaer_fant_du_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "flexjar_feedback_ditt_sykefravaer_fant_du_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når feedback ble gitt"
      },
      {
        mode        = "NULLABLE"
        name        = "svar"
        type        = "STRING"
        description = "Hva som er svart på feedbacken. Enten JA eller NEI."
      },
      {
        mode        = "NULLABLE"
        name        = "maatte_kontakte_nav"
        type        = "STRING"
        description = "Om brukeren måtte kontakte NAV."
      },
    ]
  )
  view_query = <<EOF
SELECT
  opprettet,
  JSON_VALUE(feedback_json, '$.svar') AS svar,
  JSON_VALUE(feedback_json, '$.maatteKontakteNAV') AS maatte_kontakte_nav
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flexjar_datastream.dataset_id}.public_feedback`
WHERE JSON_VALUE(feedback_json, '$.feedbackId') = 'ditt-sykefravaer-fant-du'
EOF

}

module "flexjar_feedback_sykepengesoknad_sporsmal_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "flexjar_feedback_sykepengesoknad_sporsmal_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når feedback ble gitt"
      },
      {
        mode        = "NULLABLE"
        name        = "svar"
        type        = "STRING"
        description = "Hva som er svart på feedbacken."
      },
      {
        mode        = "NULLABLE"
        name        = "sporsmal"
        type        = "STRING"
        description = "Hvilket sporsmål det ble gitt feedback på."
      },
    ]
  )
  view_query = <<EOF
SELECT
  opprettet,
  JSON_VALUE(feedback_json, '$.svar') AS svar,
  JSON_VALUE(feedback_json, '$.sporsmal') AS sporsmal
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flexjar_datastream.dataset_id}.public_feedback`
WHERE JSON_VALUE(feedback_json, '$.feedbackId') = 'sykepengesoknad-sporsmal'
EOF

}


module "flexjar_feedback_sykmelding_kvittering_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "flexjar_feedback_sykmelding_kvittering_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når feedback ble gitt"
      },
      {
        mode        = "NULLABLE"
        name        = "svar"
        type        = "STRING"
        description = "Hva som er svart på feedbacken."
      },
      {
        mode        = "NULLABLE"
        name        = "arbeidssituasjon"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "segment"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "feedback_id"
        type        = "STRING"
        description = ""
      },
    ]
  )
  view_query = <<EOF
SELECT
  opprettet,
  JSON_VALUE(feedback_json, '$.svar') AS svar,
  JSON_VALUE(feedback_json, '$.arbeidssituasjon') AS arbeidssituasjon,
  JSON_VALUE(feedback_json, '$.segment') AS segment,
  JSON_VALUE(feedback_json, '$.feedbackId') AS feedback_id
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flexjar_datastream.dataset_id}.public_feedback`
WHERE team = 'teamsykmelding'
EOF

}


