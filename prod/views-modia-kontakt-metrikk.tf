module "modia_kontakt_metrikk_henvendelse_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "modia_kontakt_metrikk_henvendelse_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "id"
        type        = "STRING"
        description = "Unik ID for henvendelsen."
      },
      {
        mode        = "NULLABLE"
        name        = "tema"
        type        = "STRING"
        description = "Hva henvendelsen gjelder."
      },
      {
        mode        = "NULLABLE"
        name        = "temagruppe"
        type        = "STRING"
        description = "Hvilken type henvendelse det er."
      },
      {
        mode        = "NULLABLE"
        name        = "traad_id"
        type        = "STRING"
        description = "Id på samtalen henvendelsen tilhører."
      },
      {
        mode        = "NULLABLE"
        name        = "tidspunkt"
        type        = "TIMESTAMP"
        description = "Tidspunkt for henvendelsen."
      },
    ]
  )
  view_query = <<EOF
SELECT id, tema, temagruppe, traad_id, tidspunkt
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.modia_kontakt_metrikk_datastream.dataset_id}.public_henvendelse`
EOF

}


module "modia_sykepengesoknad_kontakt_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "modia_sykepengesoknad_kontakt_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_uuid"
        type        = "STRING"
        description = "Unik ID for sykepengesøknaden."
      },
      {
        mode        = "NULLABLE"
        name        = "soknadstype"
        type        = "STRING"
        description = "Hvilken type sykepengesøknaden er."
      },
      {
        mode        = "NULLABLE"
        name        = "status"
        type        = "STRING"
        description = "Sykepengesøknadens status."
      },
      {
        mode        = "NULLABLE"
        name        = "sendt_arbeidsgiver"
        type        = "TIMESTAMP"
        description = "Når søknaden ble sendt til arbeidsgiver."
      },
      {
        mode        = "NULLABLE"
        name        = "sendt_nav"
        type        = "TIMESTAMP"
        description = "Når søknaden ble sendt til NAV."
      },
      {
        mode        = "NULLABLE"
        name        = "henvendelser_innen_1_uke"
        type        = "INTEGER"
        description = "Henvendelser innen 1 uke"
      },
      {
        mode        = "NULLABLE"
        name        = "henvendelser_innen_2_uker"
        type        = "INTEGER"
        description = "Henvendelser innen 2 uker"
      },
      {
        mode        = "NULLABLE"
        name        = "henvendelser_innen_4_uker"
        type        = "INTEGER"
        description = "Henvendelser innen 4 uker"
      },
      {
        mode        = "NULLABLE"
        name        = "henvendelser_innen_8_uker"
        type        = "INTEGER"
        description = "Henvendelser innen 8 uker"
      },
    ]
  )
  view_query = <<EOF
SELECT
    s.sykepengesoknad_uuid,
    max(s.soknadstype) soknadstype,
    max(s.status) status,
    max(s.sendt_arbeidsgiver) sendt_arbeidsgiver,
    max(s.sendt_nav) sendt_nav,
    COUNTIF(TIMESTAMP_DIFF(h.tidspunkt, s.sendt, DAY) <= 7) AS henvendelser_innen_1_uke,
    COUNTIF(TIMESTAMP_DIFF(h.tidspunkt, s.sendt, DAY) <= 14) AS henvendelser_innen_2_uker,
    COUNTIF(TIMESTAMP_DIFF(h.tidspunkt, s.sendt, DAY) <= 28) AS henvendelser_innen_4_uker,
    COUNTIF(TIMESTAMP_DIFF(h.tidspunkt, s.sendt, DAY) <= 56) AS henvendelser_innen_8_uker
FROM
    `${var.gcp_project["project"]}.${google_bigquery_dataset.sykepengesoknad_datastream.dataset_id}.public_sykepengesoknad` AS s
LEFT JOIN
    `${var.gcp_project["project"]}.${google_bigquery_dataset.modia_kontakt_metrikk_datastream.dataset_id}.public_henvendelse` AS h
ON
  s.fnr = h.fnr AND h.tidspunkt >= s.sendt
GROUP BY
    s.sykepengesoknad_uuid
EOF

}