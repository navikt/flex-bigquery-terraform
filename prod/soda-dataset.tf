resource "google_bigquery_dataset" "soda_dataset" {
  dataset_id    = "soda_dataset"
  location      = var.gcp_project["region"]
  friendly_name = "soda_dataset"
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
}

module "sendt_sykepengesoknad_arkivering_oppgave_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "sendt_sykepengesoknad_arkivering_oppgave_avstemming"
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
  AND sendt < timestamp_sub(current_timestamp, INTERVAL 2 HOUR)
  AND sendt >= timestamp_add(timestamp_trunc(current_timestamp(), DAY), INTERVAL -7 DAY)
  AND sykepengesoknad_uuid NOT IN (
    SELECT sykepengesoknad_id FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.sykepengesoknad_arkivering_oppgave_innsending_view`
    WHERE behandlet >= timestamp_add(timestamp_trunc(current_timestamp, DAY), INTERVAL -7 DAY)
  )
EOF
}

module "spinnsyn_vedtak_datastream_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "spinnsyn_vedtak_datastream_avstemming"
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

module "sykepengesoknad_sykepengesoknad_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "sykepengesoknad_sykepengesoknad_avstemming"
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

module "flex_sykmeldinger_backend_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "flex_sykmeldinger_backend_avstemming"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
  SELECT id FROM EXTERNAL_QUERY("${var.gcp_project["project"]}.${var.gcp_project["region"]}.flex-sykmeldinger-backend",
    '''
    SELECT id FROM sykmelding
    WHERE opprettet < date_trunc('hour', current_timestamp) - INTERVAL '2 hours'
    AND opprettet > date_trunc('day', current_timestamp) - INTERVAL '2 days'
    ''')
  WHERE id NOT IN (
  SELECT id
  FROM `${var.gcp_project["project"]}.flex_sykmeldinger_backend_datastream.public_sykmelding`
    WHERE opprettet < timestamp_add(timestamp_trunc(current_timestamp, HOUR), INTERVAL -2 HOUR)
      AND opprettet >= timestamp_add(timestamp_trunc(current_timestamp, DAY), INTERVAL -2 DAY)
  )
EOF
}

module "sykmeldinger_korrelerer_med_tsm" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.soda_dataset.dataset_id
  view_id             = "sykmeldinger_korrelerer_med_tsm"
  view_schema = jsonencode(
    [
      {
        name = "match_type",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "count",
        mode = "NULLABLE",
        type = "INTEGER"
      }
    ]
  )

  view_query = <<EOF
    WITH all_sykmeldinger AS (
      SELECT
        sh.sykmelding_id,
        sh.id AS hendelse_id,
        sh.status,
        TIMESTAMP_TRUNC(sh.opprettet, SECOND) AS hendelse_opprettet
      FROM `${var.gcp_project["project"]}.${module.flex_sykmeldinger_backend_datastream.dataset_id}.public_sykmeldinghendelse` sh
      WHERE sh.opprettet < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
    ),
    all_tsm AS (
      SELECT
        tsm.sykmelding_id,
        tsm.event,
        TIMESTAMP_TRUNC(tsm.timestamp, SECOND) AS timestamp
      FROM `${var.tsm_sykmeldingstatus_view}` tsm
      WHERE tsm.event IS NOT NULL
        AND tsm.timestamp IS NOT NULL
    ),
    matching AS (
      SELECT
        sh.sykmelding_id,
        sh.hendelse_id,
        sh.status,
        sh.hendelse_opprettet,
        tsm.event,
        tsm.timestamp
      FROM all_sykmeldinger sh
      JOIN all_tsm tsm
        ON sh.sykmelding_id = tsm.sykmelding_id
        AND sh.hendelse_opprettet = tsm.timestamp
    ),
    unmatched_tsm AS (
      SELECT tsm.sykmelding_id
      FROM all_tsm tsm
      LEFT JOIN all_sykmeldinger sh
        ON tsm.sykmelding_id = sh.sykmelding_id
        AND tsm.timestamp = sh.hendelse_opprettet
      WHERE sh.sykmelding_id IS NULL
    )

    SELECT 'matching_records' AS match_type, COUNT(*) AS count
    FROM matching

    UNION ALL

    SELECT 'unmatched_tsm_records' AS match_type, COUNT(*) AS count
    FROM unmatched_tsm

    UNION ALL

    SELECT 'unmatched_sykmeldinger_records' AS match_type,
      (SELECT COUNT(*) FROM all_sykmeldinger) - (SELECT COUNT(*) FROM matching) AS count
  EOF
}
module "arkivering_oppgave_oppgavestyring_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "arkivering_oppgave_oppgavestyring_avstemming"
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

module "flexjar_feedback_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "flexjar_feedback_avstemming"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT id FROM EXTERNAL_QUERY("${var.gcp_project["project"]}.${var.gcp_project["region"]}.flexjar-backend",
  '''
  SELECT id FROM feedback
  WHERE opprettet < date_trunc('hour', current_timestamp) - INTERVAL '2 hours'
    AND opprettet > date_trunc('day', current_timestamp) - INTERVAL '2 days'
  ''')
WHERE id NOT IN (
SELECT id
FROM `${var.gcp_project["project"]}.flexjar_datastream.public_feedback`
  WHERE opprettet < timestamp_add(timestamp_trunc(current_timestamp, HOUR), INTERVAL -2 HOUR)
    AND opprettet >= timestamp_add(timestamp_trunc(current_timestamp, DAY), INTERVAL -2 DAY)
)
EOF
}

module "arkivering_oppgave_venter_pa_bomlo" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "arkivering_oppgave_venter_pa_bomlo"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT id FROM `${var.gcp_project["project"]}.arkivering_oppgave_datastream.public_oppgavestyring`
WHERE status = 'VenterPaBomlo'
EOF
}

module "flex_inntektsmelding_status_datastream_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "flex_inntektsmelding_status_datastream_avstemming"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT id FROM EXTERNAL_QUERY("${var.gcp_project["project"]}.${var.gcp_project["region"]}.flex-inntektsmelding-status",
  '''
  SELECT id FROM vedtaksperiode_behandling_status
  WHERE opprettet_database < date_trunc('hour', current_timestamp) - INTERVAL '2 hours'
    AND opprettet_database > date_trunc('day', current_timestamp) - INTERVAL '2 days'
  ''')
WHERE id NOT IN (
SELECT id
FROM `${var.gcp_project["project"]}.inntektsmelding_status_datastream.public_vedtaksperiode_behandling_status`
  WHERE opprettet_database < timestamp_add(timestamp_trunc(current_timestamp, HOUR), INTERVAL -2 HOUR)
    AND opprettet_database >= timestamp_add(timestamp_trunc(current_timestamp, DAY), INTERVAL -2 DAY)
)
EOF
}

module "forsinket_saksbehandling_varslinger_sendt_nylig" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "forsinket_saksbehandling_varslinger_sendt_nylig"
  view_schema = jsonencode(
    [
      {
        name = "status"
        type = "STRING"
      },
      {
        name = "antall"
        type = "INTEGER"
      }
    ]
  )
  view_query = <<EOF
SELECT status, count(*) antall
FROM `${var.gcp_project["project"]}.inntektsmelding_status_datastream.public_vedtaksperiode_behandling_status`
WHERE tidspunkt >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 96 HOUR)
AND status in (
  'VARSLET_MANGLER_INNTEKTSMELDING_FØRSTE',
  'VARSLET_MANGLER_INNTEKTSMELDING_ANDRE',
  'VARSLET_VENTER_PÅ_SAKSBEHANDLER_FØRSTE',
  'REVARSLET_VENTER_PÅ_SAKSBEHANDLER'
  )
GROUP BY STATUS
EOF
}

module "spinnsyn_utbetaling_spinnsyn_arkivering_avstemming" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "spinnsyn_utbetaling_spinnsyn_arkivering_avstemming"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT vedtak_id AS id
FROM `${var.gcp_project["project"]}.spinnsyn_arkivering_datastream.public_arkivert_vedtak`
WHERE opprettet < timestamp_sub(current_timestamp, INTERVAL 2 HOUR)
  AND opprettet >= timestamp_add(timestamp_trunc(current_timestamp(), DAY), INTERVAL -4 DAY)
AND vedtak_id NOT IN (
  SELECT id
FROM `${var.gcp_project["project"]}.spinnsyn_datastream.public_utbetaling`
WHERE motatt_publisert IS NOT NULL
  AND opprettet < timestamp_sub(current_timestamp, INTERVAL 2 HOUR)
  AND opprettet >= timestamp_add(timestamp_trunc(current_timestamp(), DAY), INTERVAL -4 DAY)
)
EOF
}

module "frisk_til_arbeid_vedtak_overlapp" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "frisk_til_arbeid_vedtak_overlapp"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT id FROM `${var.gcp_project["project"]}.sykepengesoknad_datastream.public_frisk_til_arbeid_vedtak`
WHERE behandlet_status = 'OVERLAPP'
EOF
}

module "frisk_til_arbeid_vedtak_arbeidssokerperiode" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "frisk_til_arbeid_vedtak_arbeidssokerperiode"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT id FROM `${var.gcp_project["project"]}.sykepengesoknad_datastream.public_frisk_til_arbeid_vedtak`
WHERE behandlet_status IN (
  'SISTE_ARBEIDSSOKERPERIODE_AVSLUTTET',
  'INGEN_ARBEIDSSOKERPERIODE'
)
EOF
}

module "frisk_til_arbeid_vedtak_ubehandlet" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "frisk_til_arbeid_vedtak_ubehandlet"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      }
    ]
  )
  view_query = <<EOF
SELECT id FROM `${var.gcp_project["project"]}.sykepengesoknad_datastream.public_frisk_til_arbeid_vedtak`
WHERE behandlet_status = 'NY'
  AND opprettet < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
EOF
}
