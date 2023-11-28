module "sykepengesoknad_arkivering_oppgave_innsending_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "sykepengesoknad_arkivering_oppgave_innsending_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_id"
        type        = "STRING"
        description = "Unik ID for sykepengesoknaden."

      },
      {
        mode        = "NULLABLE"
        name        = "journalpost_id"
        type        = "STRING"
        description = "ID til journalført sykepengesøknad."
      },
      {
        mode        = "NULLABLE"
        name        = "oppgave_id"
        type        = "STRING"
        description = "ID til oppgave opprettet i Gosys."
      },
      {
        mode        = "NULLABLE"
        name        = "behandlet"
        type        = "TIMESTAMP"
        description = "Når oppgave ble opprettet og journalført."
      },
    ]
  )

  view_query = <<EOF
SELECT sykepengesoknad_id, journalpost_id, oppgave_id, behandlet
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.arkivering_oppgave_datastream.dataset_id}.public_innsending`
EOF

}


module "sykepengesoknad_arkivering_oppgave_oppgavestyring_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "sykepengesoknad_arkivering_oppgave_oppgavestyring_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_id"
        type        = "STRING"
        description = "Unik ID for sykepengesoknaden."
      },
      {
        mode        = "NULLABLE"
        name        = "status"
        type        = "STRING"
        description = "Status som forteller om det skal opprettet oppgave eller om vi venter på melding fra Speil."
      },
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når søknaden status gjelder for ble opprettet."
      },
      {
        mode        = "NULLABLE"
        name        = "modifisert"
        type        = "TIMESTAMP"
        description = "Når status ble endret til nåværende status."
      },
      {
        mode        = "NULLABLE"
        name        = "timeout"
        type        = "TIMESTAMP"
        description = "Tidspunkt for når vi har ventet for lenge på oppgaver med status utsett og opprettet Gosys-oppgave."
      },
      {
        mode        = "NULLABLE"
        name        = "soknadstype"
        type        = "STRING"
        description = "Hvilken type sykepengesøknaden har."
      }
    ]
  )

  view_query = <<EOF
SELECT os.sykepengesoknad_id, os.status, os.opprettet, os.modifisert, os.timeout, sv.soknadstype
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.arkivering_oppgave_datastream.dataset_id}.public_oppgavestyring` os,
`${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.sykepengesoknad_sykepengesoknad_view` sv
WHERE avstemt = true
AND os.sykepengesoknad_id = sv.sykepengesoknad_uuid
EOF

}

module "sykepengesoknad_arkivering_oppgave_gosys_oppgaver_opprettet_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "sykepengesoknad_arkivering_oppgave_gosys_oppgaver_opprettet_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_id"
        type        = "STRING"
        description = "Unik ID for sykepengesoknaden."
      },
      {
        mode        = "NULLABLE"
        name        = "status"
        type        = "STRING"
        description = "Status som angir årsakt til at oppgaven ble opprettet."
      },
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når oppgave ble opprettet i Gosys."
      },
      {
        mode        = "NULLABLE"
        name        = "soknadstype"
        type        = "STRING"
        description = "Hvilken type sykepengesøknaden har."
      }
    ]
  )

  view_query = <<EOF
SELECT os.sykepengesoknad_id, os.status, os.modifisert AS opprettet, sv.soknadstype
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.arkivering_oppgave_datastream.dataset_id}.public_oppgavestyring` os,
`${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.sykepengesoknad_sykepengesoknad_view` sv
WHERE os.status IN ('Opprettet', 'OpprettetSpeilRelatert', 'OpprettetTimeout')
  AND os.modifisert >= '2022-03-07 12:37:17.000'
  AND os.sykepengesoknad_id = sv.sykepengesoknad_uuid
ORDER BY os.modifisert
EOF

}

module "sykepengesoknad_arkivering_oppgave_gosys_oppgaver_gruppert_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "sykepengesoknad_arkivering_oppgave_gosys_oppgaver_gruppert_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "dato"
        type        = "DATE"
        description = "Vedtaksdato det er gruppert på."
      },
      {
        mode        = "NULLABLE"
        name        = "status"
        type        = "STRING"
        description = "Vedtaksstatus det er gruppert på."
      },
      {
        mode        = "NULLABLE"
        name        = "soknadstype"
        type        = "STRING"
        description = "Hvilken type sykepengesøknaden har."
      },
      {
        mode        = "NULLABLE"
        name        = "antall"
        type        = "INTEGER"
        description = "Antall grupperte vedtak."
      }
    ]
  )

  view_query = <<EOF
SELECT date(os.modifisert) AS dato,
       os.status,
       sv.soknadstype,
       count(*) AS antall
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.arkivering_oppgave_datastream.dataset_id}.public_oppgavestyring` os,
`${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.sykepengesoknad_sykepengesoknad_view` sv
WHERE os.status IN ('Opprettet', 'OpprettetSpeilRelatert', 'OpprettetTimeout')
  AND os.modifisert >= '2022-03-07 13:37:17.000'
  AND os.sykepengesoknad_id = sv.sykepengesoknad_uuid
GROUP BY date(os.modifisert), os.status, sv.soknadstype
EOF

}
