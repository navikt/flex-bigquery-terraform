module "sykepengesoknad_hovedsporsmal_pivot" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_hovedsporsmal_pivot"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_uuid"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "fom"
        type = "DATE"
      },
      {
        mode = "NULLABLE"
        name = "tom"
        type = "DATE"
      },
      {
        mode = "NULLABLE"
        name = "sendt"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "status"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "FRAVAR_FOR_SYKMELDINGEN"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "TILBAKE_I_ARBEID"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "FERIE_V2"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "PERMISJON_V2"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "UTLAND_V2"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "UTLANDSOPPHOLD_SOKT_SYKEPENGER"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "ARBEID_UNDERVEIS_100_PROSENT_0"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "JOBBET_DU_GRADERT_0"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "JOBBET_DU_100_PROSENT_0"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "ARBEID_UTENFOR_NORGE"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "ANDRE_INNTEKTSKILDER"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "ANDRE_INNTEKTSKILDER_V2"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "UTDANNING"
        type = "STRING"
      }
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_hovedsporsmal_pivot_query"
  data_transfer_schedule          = "every day 06:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-02-15T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_hovedsporsmal_pivot.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT *
FROM (SELECT sykepengesoknad_uuid,
             fom,
             tom,
             sendt,
             status,
             verdi,
             sporsmal_tag
      FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_hovedsporsmal_view.bigquery_view_id}`) PIVOT
         (max(verdi)
FOR sporsmal_tag in (
'FRAVAR_FOR_SYKMELDINGEN',
'TILBAKE_I_ARBEID',
'FERIE_V2',
'PERMISJON_V2',
'UTLAND_V2',
'UTLANDSOPPHOLD_SOKT_SYKEPENGER',
'ARBEID_UNDERVEIS_100_PROSENT_0',
'JOBBET_DU_GRADERT_0',
'JOBBET_DU_100_PROSENT_0',
'ARBEID_UTENFOR_NORGE',
'ANDRE_INNTEKTSKILDER',
'ANDRE_INNTEKTSKILDER_V2',
'UTDANNING'
))
EOF

}