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

module "sykmeldinghendelser_korrelerer_med_syfosmregister" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.soda_dataset.dataset_id
  view_id             = "sykmeldinghendelser_korrelerer_med_syfosmregister"
  view_schema = jsonencode(
    [
      {
        name = "flex_summary",
        type = "STRING"
      },
      {
        name = "tsm_summary",
        type = "STRING"
      },
      {
        name = "feiltype",
        type = "STRING"
      },
      {
        name = "sykmelding_id",
        type = "STRING"
      },
      {
        name = "sykmelding_type",
        type = "STRING"
      },
      {
        name = "flex_alle_statuser",
        mode = "REPEATED",
        type = "STRING"
      },
      {
        name = "flex_alle_opprettet",
        mode = "REPEATED",
        type = "TIMESTAMP"
      },
      {
        name = "tsm_alle_statuser",
        mode = "REPEATED",
        type = "STRING"
      },
      {
        name = "tsm_alle_opprettet",
        mode = "REPEATED",
        type = "TIMESTAMP"
      },
    ]
  )

  view_query = <<EOF
WITH
flex_sykmeldinghendelse AS (
  SELECT
    sykmelding_id,
    hendelse_opprettet,
    lokalt_opprettet,
    status,
  FROM `flex-prod-af40.flex_sykmeldinger_backend_datastream.public_sykmeldinghendelse`
  WHERE lokalt_opprettet < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
),
tsm_sykmeldingstatus AS (
  SELECT
    sykmelding_id,
    timestamp,
    event,
  FROM `teamsykmelding-prod-2acd.teamsykmelding_data.sykmeldingstatus_flex`
  WHERE CASE
      WHEN event = 'APEN'
        -- APEN statuser har timestamp knytta til sykmelding mottattDato
        THEN TIMESTAMP_MILLIS(datastream_source_timestamp) < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
      ELSE timestamp < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
    END
),
flex_sykmelding_type AS (
  SELECT
    sykmelding_id,
    JSON_VALUE(sykmelding, '$.type') as sykmelding_type,
  FROM `flex_sykmeldinger_backend_datastream.public_sykmelding`
),

flex_hendelse AS (
  SELECT
    sykmelding_id,
    hendelse_opprettet,
    lokalt_opprettet,
    status AS flex_status,
    CASE status
      WHEN 'SENDT_TIL_NAV' THEN 'BEKREFTET'
      WHEN 'SENDT_TIL_ARBEIDSGIVER' THEN 'SENDT'
      WHEN 'BEKREFTET_AVVIST' THEN 'BEKREFTET'
      ELSE status
    END AS tsm_status,
  FROM flex_sykmeldinghendelse
),
tsm_hendelse AS (
  SELECT
    sykmelding_id,
    timestamp AS hendelse_opprettet,
    event AS tsm_status,
  FROM tsm_sykmeldingstatus
),
flex_hendelser AS (
  SELECT
    sykmelding_id,
    ARRAY_AGG(tsm_status ORDER BY hendelse_opprettet DESC, lokalt_opprettet DESC, tsm_status)[OFFSET(0)] as siste_status,
    ARRAY_AGG(hendelse_opprettet ORDER BY hendelse_opprettet DESC, lokalt_opprettet DESC, tsm_status)[OFFSET(0)] as siste_opprettet,
    COUNT(*) AS antall_hendelser,
    ARRAY_AGG(tsm_status ORDER BY hendelse_opprettet DESC, lokalt_opprettet DESC, tsm_status) as alle_statuser,
    ARRAY_AGG(hendelse_opprettet ORDER BY hendelse_opprettet DESC, lokalt_opprettet DESC, tsm_status) as alle_opprettet,
  FROM flex_hendelse
  GROUP BY sykmelding_id
),
tsm_hendelser AS (
  SELECT
    sykmelding_id,
    MAX_BY(tsm_status, hendelse_opprettet) as siste_status,
    MAX(hendelse_opprettet) as siste_opprettet,
    COUNT(*) AS antall_hendelser,
    ARRAY_AGG(tsm_status ORDER BY hendelse_opprettet DESC) as alle_statuser,
    ARRAY_AGG(hendelse_opprettet ORDER BY hendelse_opprettet DESC) as alle_opprettet,
  FROM tsm_hendelse
  GROUP BY sykmelding_id
),
forskjellig_siste_status AS (
  SELECT
    sykmelding_id,
    'FORSKJELLIG' AS feiltype,
    flex_hendelser.siste_status AS flex_siste_status,
    tsm_hendelser.siste_status AS tsm_siste_status,
    flex_hendelser.siste_opprettet AS flex_siste_opprettet,
    tsm_hendelser.siste_opprettet AS tsm_siste_opprettet,
    flex_hendelser.antall_hendelser AS flex_antall_hendelser,
    flex_hendelser.alle_statuser AS flex_alle_statuser,
    flex_hendelser.alle_opprettet AS flex_alle_opprettet,
    tsm_hendelser.antall_hendelser AS tsm_antall_hendelser,
    tsm_hendelser.alle_statuser AS tsm_alle_statuser,
    tsm_hendelser.alle_opprettet AS tsm_alle_opprettet,
  FROM flex_hendelser
  INNER JOIN tsm_hendelser
    USING (sykmelding_id)
  WHERE
    flex_hendelser.siste_status != tsm_hendelser.siste_status
),
manglende_status AS (
  SELECT
    sykmelding_id,
    CASE
      WHEN flex_hendelser.sykmelding_id is null then 'MANGLER_I_FLEX'
      WHEN tsm_hendelser.sykmelding_id is null then 'MANGLER_I_TSM'
    END AS feiltype,
    flex_hendelser.siste_status AS flex_siste_status,
    tsm_hendelser.siste_status AS tsm_siste_status,
    flex_hendelser.siste_opprettet AS flex_siste_opprettet,
    tsm_hendelser.siste_opprettet AS tsm_siste_opprettet,
    flex_hendelser.antall_hendelser AS flex_antall_hendelser,
    flex_hendelser.alle_statuser AS flex_alle_statuser,
    flex_hendelser.alle_opprettet AS flex_alle_opprettet,
    tsm_hendelser.antall_hendelser AS tsm_antall_hendelser,
    tsm_hendelser.alle_statuser AS tsm_alle_statuser,
    tsm_hendelser.alle_opprettet AS tsm_alle_opprettet,
  FROM flex_hendelser
  FULL OUTER JOIN tsm_hendelser
    USING (sykmelding_id)
  WHERE
    flex_hendelser.sykmelding_id is null or tsm_hendelser.sykmelding_id is null
),
alle_feil AS (
  select *
  from forskjellig_siste_status
  UNION ALL
  select *
  from manglende_status
),
manuelt_sjekket AS (
  SELECT '86ef6c53-cdb7-4196-b2b6-1f5fc6abdbfb' AS sykmelding_id
),
alle_feil_oversikt as (
  SELECT
    CONCAT(flex_siste_status, ' ', format_timestamp('%Y-%m-%d %H:%M:%S', flex_siste_opprettet, 'UTC'), ' [', flex_antall_hendelser, ']') AS flex_summary,
    CONCAT(tsm_siste_status, ' ', format_timestamp('%Y-%m-%d %H:%M:%S', tsm_siste_opprettet, 'UTC'), ' [', tsm_antall_hendelser, ']') AS tsm_summary,
    flex_sykmelding_type.sykmelding_type,
    alle_feil.*
  FROM alle_feil
  left join flex_sykmelding_type
    using (sykmelding_id)
  WHERE sykmelding_id NOT IN (
    SELECT sykmelding_id FROM manuelt_sjekket
  )
),
sykmelding_type_oversikt AS (
  SELECT
    sykmelding_type,
    feiltype,
    count(*) as antall,
    min(COALESCE(tsm_siste_opprettet, flex_siste_opprettet)) as tidligste_status,
    max(COALESCE(tsm_siste_opprettet, flex_siste_opprettet)) as seneste_status,
  FROM alle_feil_oversikt
  GROUP BY sykmelding_type, feiltype
),
final as (
  select
    flex_summary,
    tsm_summary,
    feiltype,
    sykmelding_id,
    sykmelding_type,
    flex_alle_statuser,
    flex_alle_opprettet,
    tsm_alle_statuser,
    tsm_alle_opprettet
  from alle_feil_oversikt
  ORDER BY tsm_siste_opprettet DESC
)
SELECT *
FROM final
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
        name = "forventet_aktivering_dato",
        type = "DATE"
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
  WHERE
    -- Kjent feil før dette tidspunktet
    opprettet > '2025-01-01'
),
fremtidig_sykepengesoknad AS (
  SELECT
    DATE_ADD(tom, INTERVAL 1 DAY) AS forventet_aktivering_dato,
    *
  FROM sykepengesoknad
  WHERE status = 'FREMTIDIG'
),
ikke_aktivert AS (
  SELECT
    *,
    DATE_DIFF(CURRENT_DATE(), forventet_aktivering_dato, DAY) AS aktivering_forsinket_dager
  FROM fremtidig_sykepengesoknad
  WHERE forventet_aktivering_dato < CURRENT_DATE()
)
SELECT
  id,
  sykepengesoknad_uuid,
  forventet_aktivering_dato,
  aktivering_forsinket_dager,
  soknadstype,
  fom,
  tom
FROM ikke_aktivert
EOF
}
