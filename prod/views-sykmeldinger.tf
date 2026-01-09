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
        name = "sykmelding_hendelse_oppdatert",
        mode = "NULLABLE",
        type = "TIMESTAMP"
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
      },
      {
        name = "statuses",
        mode = "REPEATED",
        type = "RECORD",
        fields = [
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
            name = "hendelse_opprettet_timestamp",
            mode = "NULLABLE",
            type = "TIMESTAMP"
          },
          {
            name = "lokalt_opprettet",
            mode = "NULLABLE",
            type = "TIMESTAMP"
          }
        ]
      }
    ]
  )

  view_query = <<EOF
     SELECT
        sm.sykmelding_id,
        sm.fnr,
        ANY_VALUE(sm.sykmelding) AS sykmelding,
        ANY_VALUE(sm.opprettet) AS sykmelding_opprettet,
        ANY_VALUE(sm.hendelse_oppdatert) AS sykmelding_hendelse_oppdatert,
        ANY_VALUE(sm.validation) AS validation,
        ANY_VALUE(sm.sykmelding_grunnlag_oppdatert) AS sykmelding_grunnlag_oppdatert,
        ANY_VALUE(sm.validation_oppdatert) AS validation_oppdatert,
        ARRAY_AGG(
            STRUCT(
                smh.status,
                smh.tidligere_arbeidsgiver,
                smh.bruker_svar,
                smh.tilleggsinfo,
                smh.source,
                smh.hendelse_opprettet AS hendelse_opprettet_timestamp,
                smh.lokalt_opprettet
            ) IGNORE NULLS
            ORDER BY smh.hendelse_opprettet
        ) AS statuses
    FROM
        `flex-prod-af40.flex_sykmeldinger_backend_datastream.public_sykmelding` sm
    LEFT JOIN
        `flex-prod-af40.flex_sykmeldinger_backend_datastream.public_sykmeldinghendelse` smh
        ON sm.sykmelding_id = smh.sykmelding_id
    GROUP BY
        sm.sykmelding_id,
        sm.fnr
  EOF
}

module "sykmeldinger_siste_hendelse_brukersvar_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykmeldinger_siste_hendelse_brukersvar_view"
  view_schema = jsonencode(
    [
      {
        name = "sykmelding_id",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "sykmelding_opprettet",
        mode = "NULLABLE",
        type = "TIMESTAMP"
      },
      {
        name = "hendelse_opprettet",
        mode = "NULLABLE",
        type = "TIMESTAMP"
      },
      {
        name = "status",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "arbeidssituasjon",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "erOpplysningeneRiktige",
        mode = "NULLABLE",
        type = "BOOL"
      },
      {
        name = "riktigNarmesteLeder",
        mode = "NULLABLE",
        type = "BOOL"
      },
      {
        name = "harEgenmeldingsdager",
        mode = "NULLABLE",
        type = "BOOL"
      },
      {
        name = "harBruktEgenmelding",
        mode = "NULLABLE",
        type = "BOOL"
      },
      {
        name = "harForsikring",
        mode = "NULLABLE",
        type = "BOOL"
      }
    ]
  )

  view_query = <<EOF
      SELECT sm.sykmelding_id                                                                 as sykmelding_id,
             sm.opprettet                                                                     AS sykmelding_opprettet,
             siste_smh.hendelse_opprettet                                                     AS hendelse_opprettet,
             siste_smh.status                                                                 as status,
             JSON_VALUE(siste_smh.bruker_svar, '$.arbeidssituasjon.svar')                     AS arbeidssituasjon,
             CAST(JSON_VALUE(siste_smh.bruker_svar, '$.erOpplysningeneRiktige.svar') AS BOOL) AS erOpplysningeneRiktige,
             CAST(JSON_VALUE(siste_smh.bruker_svar, '$.riktigNarmesteLeder.svar') AS BOOL)    AS riktigNarmesteLeder,
             CAST(JSON_VALUE(siste_smh.bruker_svar, '$.harEgenmeldingsdager.svar') AS BOOL)   AS harEgenmeldingsdager,
             CAST(JSON_VALUE(siste_smh.bruker_svar, '$.harBruktEgenmelding.svar') AS BOOL)    AS harBruktEgenmelding,
             CAST(JSON_VALUE(siste_smh.bruker_svar, '$.harForsikring.svar') AS BOOL)          AS harForsikring

      FROM `${var.gcp_project["project"]}.${module.flex_sykmeldinger_backend_datastream.dataset_id}.public_sykmelding` sm
               JOIN (SELECT *
                     FROM `${var.gcp_project["project"]}.${module.flex_sykmeldinger_backend_datastream.dataset_id}.public_sykmeldinghendelse`

                     QUALIFY ROW_NUMBER() OVER (
                         PARTITION BY sykmelding_id
                         ORDER BY hendelse_opprettet DESC
                         ) = 1) siste_smh ON sm.sykmelding_id = siste_smh.sykmelding_id
      where siste_smh.bruker_svar is not null
    EOF
}
