module "sykmeldinger_med_hendelser_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykmeldinger_med_hendelser_view"
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
        name = "sykmelding",
        mode = "NULLABLE",
        type = "JSON"
      },
      {
        name = "sykmelding_opprettet",
        mode = "NULLABLE",
        type = "TIMESTAMP"
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
        sm.sykmelding_id,
        sm.fnr,
        sm.sykmelding,
        sm.opprettet AS sykmelding_opprettet,
        sm.meldingsinformasjon,
        sm.validation,
        sm.sykmelding_grunnlag_oppdatert,
        sm.validation_oppdatert,
        smh.status,
        smh.tidligere_arbeidsgiver,
        smh.arbeidstaker_info,
        smh.bruker_svar,
        smh.tilleggsinfo,
        smh.source,
        smh.opprettet AS hendelse_opprettet,
        smh.lokalt_opprettet
      FROM `flex-prod-af40.flex_sykmeldinger_backend_datastream.public_sykmelding` sm
      INNER JOIN `flex-prod-af40.flex_sykmeldinger_backend_datastream.public_sykmeldinghendelse` smh
        ON sm.sykmelding_id = smh.sykmelding_id
  EOF
}