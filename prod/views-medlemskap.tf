module "medlemskap_uavklart_gosys_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "medlemskap_uavklart_gosys_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_uuid"
        type        = "STRING"
        description = "Søknadens unike ID som vist til bruker."
      },
      {
        mode        = "NULLABLE"
        name        = "fom"
        type        = "DATE"
        description = "Søknadens fra- og med-dato."
      },
      {
        mode        = "NULLABLE"
        name        = "tom"
        type        = "DATE"
        description = "Søknadens til- og med-dato."
      },
      {
        mode        = "NULLABLE"
        name        = "inngaende_vurdering"
        type        = "STRING"
        description = "Medlemskapsvurdering før Team LovMe har mottatt brukers svar på spørsmål."
      },
      {
        mode        = "NULLABLE"
        name        = "endelig_vurdering"
        type        = "STRING"
        description = "Medlemskapsvurdering etter at Team LovMe har prosesserte brukers svar på spørsmål."
      },
      {
        mode        = "NULLABLE"
        name        = "status"
        type        = "STRING"
        description = "Status på potensiell Gosys-oppgave."
      },
      {
        mode        = "NULLABLE"
        name        = "modifisert"
        type        = "TIMESTAMP"
        description = "Når Gosys-oppgaven ble opprettet."
      },
      {
        mode        = "NULLABLE"
        name        = "sporsmal"
        type        = "JSON"
        description = "Hvilke medlemskapsrelaterte spørsmål brukeren fikk."
      },
    ]
  )
  view_query = <<EOF
SELECT
  a.sykepengesoknad_id AS sykepengesoknad_uuid, a.fom, a.tom, a.inngaende_vurdering, a.endelig_vurdering,
  b.status,
  b.modifisert,
  c.sporsmal,
FROM `${var.gcp_project["project"]}.${module.arkivering_oppgave_datastream.dataset_id}.public_medlemskap_vurdering` a
INNER JOIN `${var.gcp_project["project"]}.${module.arkivering_oppgave_datastream.dataset_id}.public_oppgavestyring` b ON b.sykepengesoknad_id = a.sykepengesoknad_id
INNER JOIN `${var.gcp_project["project"]}.${module.sykepengesoknad_datastream.dataset_id}.public_medlemskap_vurdering` c ON c.sykepengesoknad_id  = a.sykepengesoknad_id
WHERE inngaende_vurdering = 'UAVKLART'
  AND endelig_vurdering = 'UAVKLART'
  AND c.sporsmal IS NOT NULL
ORDER BY b.modifisert DESC;
EOF
}


