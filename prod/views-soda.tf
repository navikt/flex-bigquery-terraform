module "soda_sendt_sykepengesoknad_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "soda-sendt-sykepengesoknad-avstemming-view"
  view_schema = jsonencode(
    [
      {
        name = "sykepengesoknad_uuid"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT sykepengesoknad_uuid
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.sykepengesoknad_sykepengesoknad_view`
WHERE status = 'SENDT'
  AND sendt < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 HOUR)
  AND sendt >= TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY), INTERVAL -7 DAY)
  AND sykepengesoknad_uuid NOT IN (
    SELECT sykepengesoknad_id FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.sykepengesoknad_arkivering_oppgave_innsending_view`
    WHERE behandlet >= TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY), INTERVAL -7 DAY)
  )
EOF
}

module "soda_spinnsyn_datastream_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "soda-spinnsyn-datastream-avstemming"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT id FROM EXTERNAL_QUERY("${var.gcp_project["project"]}.${var.gcp_project["region"]}.spinnsyn-backend",
  '''
  SELECT id FROM vedtak_v2
  WHERE opprettet < date_trunc('hour', current_timestamp) - INTERVAL '2 hours'
    AND opprettet > date_trunc('day', current_timestamp) - INTERVAL '2 days'
  ''')
WHERE id NOT IN (
SELECT id
FROM `${var.gcp_project["project"]}.spinnsyn_datastream.public_vedtak_v2`
  WHERE opprettet < timestamp_add(timestamp_trunc(current_timestamp, HOUR), INTERVAL -2 HOUR)
    AND opprettet >= timestamp_add(timestamp_trunc(current_timestamp, DAY), INTERVAL -2 DAY)
)
EOF
}

module "soda_sykepengesoknad_datastream_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "soda-sykepengesoknad-datastream-avstemming"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT id FROM EXTERNAL_QUERY("${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-backend",
  '''
  SELECT id FROM sykepengesoknad
  WHERE opprettet < date_trunc('hour', current_timestamp) - INTERVAL '2 hours'
    AND opprettet > date_trunc('day', current_timestamp) - INTERVAL '2 days'
  ''')
WHERE id NOT IN (
SELECT id
FROM `${var.gcp_project["project"]}.sykepengesoknad_datastream.public_sykepengesoknad`
  WHERE opprettet < timestamp_add(timestamp_trunc(current_timestamp, HOUR), INTERVAL -2 HOUR)
    AND opprettet >= timestamp_add(timestamp_trunc(current_timestamp, DAY), INTERVAL -2 DAY)
)
EOF
}

module "soda_arkivering_oppgave_datastream_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "soda-arkivering-oppgave-datastream-avstemming"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT id FROM EXTERNAL_QUERY("${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-arkivering-oppgave",
  '''
  SELECT id FROM oppgavestyring
  WHERE opprettet < date_trunc('hour', current_timestamp) - INTERVAL '2 hours'
    AND opprettet > date_trunc('day', current_timestamp) - INTERVAL '2 days'
  ''')
WHERE id NOT IN (
SELECT id
FROM `${var.gcp_project["project"]}.arkivering_oppgave_datastream.public_oppgavestyring`
  WHERE opprettet < timestamp_add(timestamp_trunc(current_timestamp, HOUR), INTERVAL -2 HOUR)
    AND opprettet >= timestamp_add(timestamp_trunc(current_timestamp, DAY), INTERVAL -2 DAY)
)
EOF
}