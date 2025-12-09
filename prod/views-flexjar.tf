module "flexjar_feedback_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "flexjar_feedback_view"
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
        name        = "team"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "app"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "tags"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "svar"
        type        = "STRING"
        description = "Hva som er svart på feedbacken."
      },
      {
        mode        = "NULLABLE"
        name        = "svar_number"
        type        = "INTEGER"
        description = "Hva som er svart på feedbacken."
      },
      {
        mode        = "NULLABLE"
        name        = "soknadstype"
        type        = "STRING"
        description = "Hvilken soknadstype det ble gitt feedback på."
      },
      {
        mode        = "NULLABLE"
        name        = "feedbackId"
        type        = "STRING"
        description = ""
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
        name        = "sporsmal"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "er_refusjon"
        type        = "BOOLEAN"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "har_avviste_dager"
        type        = "BOOLEAN"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "er_direkteutbetaling"
        type        = "BOOLEAN"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "annullert"
        type        = "BOOLEAN"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "revurdert"
        type        = "BOOLEAN"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "svar_emoji"
        type        = "STRING"
        description = "Hva som er svart på feedbacken som emoji."
      },
      {
        mode        = "NULLABLE"
        name        = "aarsak"
        type        = "STRING"
        description = "Valgt årsak til svar."
      },
      {
        mode        = "NULLABLE"
        name        = "julesoknad"
        type        = "BOOLEAN"
        description = "Er julesøknad"
      }
    ]
  )
  view_query = <<EOF
SELECT opprettet,
       team,
       app,
       tags,
       JSON_VALUE(feedback_json, '$.svar')                              AS svar,
       SAFE_CAST(JSON_VALUE(feedback_json, '$.svar') AS INTEGER)        AS svar_number,
       JSON_VALUE(feedback_json, '$.soknadstype')                       AS soknadstype,
       JSON_VALUE(feedback_json, '$.feedbackId')                        AS feedbackId,
       JSON_VALUE(feedback_json, '$.arbeidssituasjon')                  AS arbeidssituasjon,
       JSON_VALUE(feedback_json, '$.segment')                           AS segment,
       JSON_VALUE(feedback_json, '$.sporsmal')                          AS sporsmal,
       CAST(JSON_VALUE(feedback_json, '$.erRefusjon') AS BOOL)          AS er_refusjon,
       CAST(JSON_VALUE(feedback_json, '$.harAvvisteDager') AS BOOL)     AS har_avviste_dager,
       CAST(JSON_VALUE(feedback_json, '$.erDirekteutbetaling') AS BOOL) AS er_direkteutbetaling,
       CAST(JSON_VALUE(feedback_json, '$.annullert') AS BOOL)           AS annullert,
       CAST(JSON_VALUE(feedback_json, '$.revurdert') AS BOOL)           AS revurdert,
       CASE SAFE_CAST(JSON_VALUE(feedback_json, '$.svar') AS INTEGER)
           WHEN 1 THEN '😡'
           WHEN 2 THEN '🙁'
           WHEN 3 THEN '😐'
           WHEN 4 THEN '🙂'
           WHEN 5 THEN '😍'
           END                                                             svar_emoji,
       JSON_VALUE(feedback_json, '$.aarsak')                            AS aarsak,
       CAST(JSON_VALUE(feedback_json, '$.julesøknad') AS BOOL)          AS julesoknad
FROM `${var.gcp_project["project"]}.${module.flexjar_datastream.dataset_id}.public_feedback`
where (
  JSON_VALUE(feedback_json, '$.svar') in ('JA', 'NEI', 'FORBEDRING', '1', '2', '3', '4', '5', 'Ja', 'Nei', 'Mangelfull eller uriktig rapportering til A-ordningen')
   OR
  JSON_VALUE(feedback_json, '$.feedbackId') in ('sykpengesoknad-avbryt-survey', 'sykpengesoknad-gjenapne-survey', 'sykepengesoknad-sporsmal-v2')
)
EOF
}

module "flexjar_syfooversikt_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "flexjar_syfooversikt_view"
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
        name        = "team"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "app"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "tags"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "svar"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "feedbackId"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "feedback"
        type        = "STRING"
        description = ""
      },
    ]
  )
  view_query = <<EOF
SELECT opprettet,
       team,
       app,
       tags,
       JSON_VALUE(feedback_json, '$.svar')                              AS svar,
       JSON_VALUE(feedback_json, '$.feedbackId')                        AS feedbackId,
       JSON_VALUE(feedback_json, '$.feedback')                          AS feedback
FROM `${var.gcp_project["project"]}.${module.flexjar_datastream.dataset_id}.public_feedback`
WHERE (app = 'syfooversikt' or app = 'syfomodiaperson')
AND team = 'teamsykefravr'
AND (JSON_VALUE(feedback_json, '$.feedbackId') = 'Min oversikt' OR JSON_VALUE(feedback_json, '$.feedbackId') = 'SenFase' OR JSON_VALUE(feedback_json, '$.feedbackId') = 'Historikk' OR JSON_VALUE(feedback_json, '$.feedbackId') = 'Min oversikt - Ruting' OR JSON_VALUE(feedback_json, '$.feedbackId') = 'Enhetens oversikt - Ruting')
EOF
}

module "flexjar_esyfo_oppfolgingsplan_frontend_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "flexjar_esyfo_oppfolgingsplan_frontend_view"
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
        name        = "tags"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "feedbackId"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "sporsmal_1"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "svar_1"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "sporsmal_2"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "svar_2"
        type        = "STRING"
        description = ""
      },
    ]
  )
  view_query = <<EOF
SELECT opprettet,
       tags,
       JSON_VALUE(feedback_json, '$.feedbackId')          AS feedbackId,
       JSON_VALUE(feedback_json, '$.question__feedback')  AS sporsmal_1,
       JSON_VALUE(feedback_json, '$.feedback')            AS svar_1,
       JSON_VALUE(feedback_json, '$.question__svar')      AS sporsmal_2,
       JSON_VALUE(feedback_json, '$.svar')                AS svar_2
FROM `${var.gcp_project["project"]}.${module.flexjar_datastream.dataset_id}.public_feedback`
where team = 'team-esyfo'
  and app='oppfolgingsplan-frontend'
EOF
}