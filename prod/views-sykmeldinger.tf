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

module "sykmeldinger_korrelerer_med_tsm_aggregert" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykmeldinger_korrelerer_med_tsm_aggregert"
  view_schema = jsonencode(
    [
      {
        name = "uoverensstemmelse_type",
        mode = "NULLABLE",
        type = "STRING"
      },
      {
        name = "antall",
        mode = "NULLABLE",
        type = "INTEGER"
      }
    ]
  )

  view_query = <<EOF
    -- Dette viewet vil returnere aggregerte tall basert på rådata fra sykmeldinger_korrelerer_med_tsm
    WITH raw_data AS (
      SELECT
        uoverensstemmelse_type,
        flex_status,
        tsm_event
      FROM
        `${var.gcp_project["project"]}.${google_bigquery_dataset.soda_dataset.dataset_id}.sykmeldinger_korrelerer_med_tsm`
    )

    -- Aggregerte tall for hver uoverensstemmelsestype
    (
      SELECT
        'sykmeldingstatus_ikke_i_flex' AS uoverensstemmelse_type,
        COUNT(*) AS antall
      FROM
        raw_data
      WHERE
        uoverensstemmelse_type = 'sykmeldingstatus_ikke_i_flex'
      HAVING
        COUNT(*) > 0
    )
    UNION ALL
    (
      SELECT
        'sykmeldinghendelser_ikke_i_tsm' AS uoverensstemmelse_type,
        COUNT(*) AS antall
      FROM
        raw_data
      WHERE
        uoverensstemmelse_type = 'sykmeldinghendelser_ikke_i_tsm'
      HAVING
        COUNT(*) > 0
    )
    UNION ALL
    (
      SELECT
        'status_mismatch_total' AS uoverensstemmelse_type,
        COUNT(*) AS antall
      FROM
        raw_data
      WHERE
        uoverensstemmelse_type = 'status_mismatch'
      HAVING
        COUNT(*) > 0
    )
    UNION ALL
    (
      SELECT
        CONCAT('status_mismatch: flex_status: ', flex_status, ' vs tsm_event: ', tsm_event) AS uoverensstemmelse_type,
        COUNT(*) AS antall
      FROM
        raw_data
      WHERE
        uoverensstemmelse_type = 'status_mismatch'
      GROUP BY
        flex_status,
        tsm_event
      HAVING
        COUNT(*) > 0
    );
  EOF
}