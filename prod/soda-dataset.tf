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
        name = "sykmelding_id",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "uoverensstemmelse_type",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "flex_status",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "tsm_event",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "tsm_tidspunkt",
        mode = "NULLABLE",
        type = "TIMESTAMP"
      },
      {
        name = "flex_tidspunkt",
        mode = "NULLABLE",
        type = "TIMESTAMP"
      }
    ]
  )

  view_query = <<EOF

    -- Dette viewet viser detaljerte data for uoverensstemmelser mellom systemer
    WITH
    flex_sykmeldinghendelse AS (
      SELECT *
      FROM `${var.gcp_project["project"]}.${module.flex_sykmeldinger_backend_datastream.dataset_id}.public_sykmeldinghendelse`
    ),
    tsm_sykmeldingstatus AS (
      SELECT *
      FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.team_sykmelding_sykmeldingstatuser`
    ),
    alle_sykmeldinger AS (
      SELECT
        sh.sykmelding_id,
        sh.status,
        sh.hendelse_opprettet AS hendelse_opprettet_tidspunkt,
        TIMESTAMP_TRUNC(sh.hendelse_opprettet, SECOND) AS hendelse_opprettet_tidspunkt_truncated
      FROM
        flex_sykmeldinghendelse sh
      WHERE
        hendelse_opprettet < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
    ),
    alle_tsm_statuser AS (
      SELECT
        tsm.sykmelding_id,
        tsm.event,
        tsm.timestamp AS tsm_tidspunkt,
        TIMESTAMP_TRUNC(tsm.timestamp, SECOND) AS tsm_tidspunkt_truncated
      FROM
        tsm_sykmeldingstatus tsm
      WHERE
        event IS NOT NULL
        AND timestamp IS NOT NULL
        AND event != 'AVBRUTT' -- Ekskluderer AVBRUTT-statuser
        AND tsm.timestamp < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
    )

    -- Uoverensstemmelse type 1: TSM statuser som ikke har matching i Flex
    SELECT
      tsm.sykmelding_id,
      'sykmeldingstatus_ikke_i_flex' AS uoverensstemmelse_type,
      NULL AS flex_status,
      tsm.event AS tsm_event,
      NULL AS flex_tidspunkt,
      tsm.tsm_tidspunkt AS tsm_tidspunkt
    FROM
      alle_tsm_statuser tsm
      LEFT JOIN alle_sykmeldinger sh
        ON tsm.sykmelding_id = sh.sykmelding_id
        AND tsm.tsm_tidspunkt_truncated = sh.hendelse_opprettet_tidspunkt_truncated
    WHERE
      sh.sykmelding_id IS NULL

    UNION ALL

    -- Uoverensstemmelse type 2: Flex hendelser som ikke har matching i TSM
    SELECT
      sh.sykmelding_id,
      'sykmeldinghendelser_ikke_i_tsm' AS uoverensstemmelse_type,
      sh.status AS flex_status,
      NULL AS tsm_event,
      sh.hendelse_opprettet_tidspunkt AS flex_tidspunkt,
      NULL AS tsm_tidspunkt
    FROM
      alle_sykmeldinger sh
      LEFT JOIN alle_tsm_statuser tsm
        ON sh.sykmelding_id = tsm.sykmelding_id
        AND sh.hendelse_opprettet_tidspunkt_truncated = tsm.tsm_tidspunkt_truncated
    WHERE
      tsm.sykmelding_id IS NULL

    UNION ALL

    -- Uoverensstemmelse type 3: Status/event verdier er ulike
    SELECT
      sh.sykmelding_id,
      'status_mismatch' AS uoverensstemmelse_type,
      sh.status AS flex_status,
      tsm.event AS tsm_event,
      sh.hendelse_opprettet_tidspunkt AS flex_tidspunkt,
      tsm.tsm_tidspunkt AS tsm_tidspunkt
    FROM
      alle_sykmeldinger sh
      JOIN alle_tsm_statuser tsm
        ON sh.sykmelding_id = tsm.sykmelding_id
        AND sh.hendelse_opprettet_tidspunkt_truncated = tsm.tsm_tidspunkt_truncated
    WHERE
      CASE
        WHEN sh.status = 'APEN' THEN tsm.event != 'APEN'
        WHEN sh.status = 'SENDT_TIL_ARBEIDSGIVER' THEN tsm.event != 'SENDT'
        WHEN sh.status = 'SENDT_TIL_NAV' THEN tsm.event != 'BEKREFTET'
        WHEN sh.status = 'UTGATT' THEN tsm.event != 'UTGATT'
      END
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

module "flex_inntektsmelding_status_forelagte_opplysninger_forsinket" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "flex_inntektsmelding_status_forelagte_opplysninger_forsinket"

  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      },
      {
        name = "vedtaksperiode_id"
        type = "STRING"
      },
      {
        name = "behandling_id"
        type = "STRING"
      },
      {
        name = "opprinnelig_opprettet"
        type = "TIMESTAMP"
      },
      {
        name = "forsinket_dager"
        type = "INTEGER"
      }
    ]
  )

  view_query = <<EOF
WITH
  forelagte_opplysninger AS (
    SELECT *
    FROM `flex-prod-af40.inntektsmelding_status_datastream.public_forelagte_opplysninger_ainntekt`
  ),
  forsinkede AS (
    SELECT
      *,
      TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), opprinnelig_opprettet, DAY) AS forsinket_dager
    FROM forelagte_opplysninger
    WHERE status = 'NY'
  )
SELECT
  id,
  vedtaksperiode_id,
  behandling_id,
  opprinnelig_opprettet,
  forsinket_dager
FROM forsinkede
WHERE forsinket_dager > 5
EOF
}

module "sykepengesoknad_aktivering_forsinket" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false

  dataset_id = google_bigquery_dataset.soda_dataset.dataset_id
  view_id    = "sykepengesoknad_aktivering_forsinket"

  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "STRING"
      },
      {
        name = "sykepengesoknad_uuid"
        type = "STRING"
      },
      {
        name = "aktivering_forsinket_dager"
        type = "INTEGER"
      },
      {
        name = "soknadstype"
        type = "STRING"
      },
      {
        name = "fom"
        type = "DATE"
      },
      {
        name = "tom"
        type = "DATE"
      }
    ]
  )

  view_query = <<EOF
WITH
sykepengesoknad AS (
  SELECT *
  FROM `flex-prod-af40.flex_dataset.sykepengesoknad_sykepengesoknad_view`
),
fremtidig_sykepengesoknad AS (
  SELECT
    DATE_DIFF(
      CURRENT_DATE(),
      DATE_ADD(tom, INTERVAL 1 DAY),
      DAY
    ) AS aktivering_forsinket_dager,
    *
  FROM sykepengesoknad
  WHERE status = 'FREMTIDIG'
),
ikke_aktivert AS (
  SELECT *
  FROM fremtidig_sykepengesoknad
  WHERE aktivering_forsinket_dager >= 1
)
SELECT
  id,
  sykepengesoknad_uuid,
  aktivering_forsinket_dager,
  soknadstype,
  fom,
  tom,
FROM ikke_aktivert
EOF
}
