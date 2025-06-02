module "sykmeldinger_med_hendelser_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykmeldinger_med_hendelser_view"
  view_schema = jsonencode(
    [
      {
        name = "id",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "sykmelding_id",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "fnr",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "sykmelding",
        mode = "NULLABLE",
        type = "JSON"
      },
      {
        name = "opprettet",
        mode = "NULLABLE",
        type = "TIMESTAMP"
      },
      {
        name = "hendelse_id",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "status",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "tidligere_arbeidsgiver",
        mode = "NULLABLE",
        type = "JSON"
      },
      {
        name = "arbeidstaker_info",
        mode = "NULLABLE",
        type = "JSON"
      },
      {
        name = "bruker_svar",
        mode = "NULLABLE",
        type = "JSON"
      },
      {
        name = "tilleggsinfo",
        mode = "NULLABLE",
        type = "JSON"
      },
      {
        name = "source",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "hendelse_opprettet",
        mode = "NULLABLE",
        type = "TIMESTAMP"
      },
      {
        name = "lokalt_opprettet",
        mode = "NULLABLE",
        type = "TIMESTAMP"
      },
      {
        name = "meldingsinformasjon",
        mode = "NULLABLE",
        type = "JSON"
      },
      {
        name = "validation",
        mode = "NULLABLE",
        type = "JSON"
      },
      {
        name = "sykmelding_grunnlag_oppdatert",
        mode = "NULLABLE",
        type = "TIMESTAMP"
      },
      {
        name = "validation_oppdatert",
        mode = "NULLABLE",
        type = "TIMESTAMP"
      }
    ]
  )

  view_query = <<EOF
    SELECT
      public_sykmelding.sykmelding_id,
      public_sykmelding.fnr,
      public_sykmelding.sykmelding,
      public_sykmelding.opprettet AS sykmelding_opprettet,
      public_sykmeldinghendelse.status,
      public_sykmeldinghendelse.tidligere_arbeidsgiver,
      public_sykmeldinghendelse.arbeidstaker_info,
      public_sykmeldinghendelse.bruker_svar,
      public_sykmeldinghendelse.tilleggsinfo,
      public_sykmeldinghendelse.source,
      public_sykmeldinghendelse.opprettet AS hendelse_opprettet,
      public_sykmeldinghendelse.lokalt_opprettet,
      public_sykmeldinghendelse.meldingsinformasjon,
      public_sykmeldinghendelse.validation,
      public_sykmeldinghendelse.sykmelding_grunnlag_oppdatert,
      public_sykmeldinghendelse.validation_oppdatert
    FROM `${var.gcp_project["project"]}.${module.flex_sykmeldinger_backend_datastream.dataset_id}.public_sykmelding`
    INNER JOIN `${var.gcp_project["project"]}.${module.flex_sykmeldinger_backend_datastream.dataset_id}.public_sykmeldinghendelse`
    ON public_sykmelding.sykmelding_id = public_sykmeldinghendelse.sykmelding_id
  EOF
}

module "sykmeldinger_korrelerer_med_tsm" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykmeldinger_korrelerer_med_tsm_view"
  view_schema = jsonencode(
    [
      {
        name = "sykmelding_id",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "fnr",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "hendelse_id",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "status",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "event",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "hendelse_opprettet",
        mode = "NULLABLE",
        type = "TIMESTAMP"
      },
      {
        name = "timestamp",
        mode = "NULLABLE",
        type = "TIMESTAMP"
      }
    ]
  )

  view_query = <<EOF
    SELECT
      COALESCE(sh.sykmelding_id, tsm.sykmelding_id) AS sykmelding_id,
      sm.fnr,
      sh.id AS hendelse_id,
      sh.status,
      tsm.event,
      sh.opprettet AS hendelse_opprettet,
      tsm.timestamp
    FROM `${var.gcp_project["project"]}.${module.flex_sykmeldinger_backend_datastream.dataset_id}.public_sykmelding` sm
    FULL OUTER JOIN `${var.gcp_project["project"]}.${module.flex_sykmeldinger_backend_datastream.dataset_id}.public_sykmeldinghendelse` sh
      ON sm.sykmelding_id = sh.sykmelding_id
    FULL OUTER JOIN `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.public_temp_tsm_historisk_sykmeldingstatus` tsm
      ON sh.sykmelding_id = tsm.sykmelding_id
      AND sh.opprettet = tsm.timestamp
    WHERE (sh.sykmelding_id IS NULL OR tsm.sykmelding_id IS NULL OR sh.status != tsm.event)
      AND (sh.opprettet IS NULL OR sh.opprettet < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR))
  EOF
}