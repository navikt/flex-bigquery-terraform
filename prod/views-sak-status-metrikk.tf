module "sykepengesoknad_sak_status_metrikk_tilstand_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykepengesoknad_sak_status_metrikk_tilstand_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_uuid"
        type        = "STRING"
        description = "Unik ID for sykepengesøknaden opprettet av Team Flex."
      },
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_at_id"
        type        = "STRING"
        description = "Unik ID for sykepengesøknaden opprettet av Bømlo."
      },
      {
        mode        = "NULLABLE"
        name        = "vedtaksperiode_id"
        type        = "STRING"
        description = "Unik ID for vedtaksperiode opprettet av Bømlo."
      },
      {
        mode        = "NULLABLE"
        name        = "tilstand"
        type        = "STRING"
        description = "Tilstand i vedtaksperiodens tilstandshistorikk."
      },
      {
        mode        = "NULLABLE"
        name        = "tidspunkt"
        type        = "TIMESTAMP"
        description = "Tildpunktet tilstanden ble opprettet."
      }
    ]
  )

  view_query = <<EOF
SELECT a.sykepengesoknad_uuid, a.sykepengesoknad_at_id, c.vedtaksperiode_id, c.tilstand, c.tidspunkt
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.sak_status_metrikk_datastream.dataset_id}.public_sykepengesoknad_id` a
  INNER JOIN `${var.gcp_project["project"]}.${google_bigquery_dataset.sak_status_metrikk_datastream.dataset_id}.public_sykepengesoknad_vedtaksperiode` b ON b.sykepengesoknad_at_id = a.sykepengesoknad_at_id
  INNER JOIN `${var.gcp_project["project"]}.${google_bigquery_dataset.sak_status_metrikk_datastream.dataset_id}.public_vedtaksperiode_tilstand` c on c.vedtaksperiode_id = b.vedtaksperiode_id
EOF

}

module "sykepengesoknad_sak_status_metrikk_siste_tilstand_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykepengesoknad_sak_status_metrikk_siste_tilstand_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_uuid"
        type        = "STRING"
        description = "Unik ID for sykepengesøknaden opprettet av Team Flex."
      },
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_at_id"
        type        = "STRING"
        description = "Unik ID for sykepengesøknaden opprettet av Bømlo."
      },
      {
        mode        = "NULLABLE"
        name        = "vedtaksperiode_id"
        type        = "STRING"
        description = "Unik ID for vedtaksperiode opprettet av Bømlo."
      },
      {
        mode        = "NULLABLE"
        name        = "tilstand"
        type        = "STRING"
        description = "Tilstand i vedtaksperiodens tilstandshistorikk."
      },
      {
        mode        = "NULLABLE"
        name        = "tidspunkt"
        type        = "TIMESTAMP"
        description = "Tildpunktet tilstanden ble opprettet."
      },
      {
        mode        = "NULLABLE"
        name        = "funksjonell_feil"
        type        = "STRING"
        description = "Alle distincte funksjonelle feil concatet med komma."
      },
      {
        mode        = "NULLABLE"
        name        = "forkastet"
        type        = "BOOLEAN"
        description = "Om vedtaksperioden er forkastet."
      }
    ]
  )

  view_query = <<EOF
SELECT a.sykepengesoknad_uuid, a.sykepengesoknad_at_id, c.vedtaksperiode_id, c.tilstand, c.tidspunkt, f.funksjonell_feil, IFNULL(t.forkastet, false) forkastet
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.sak_status_metrikk_datastream.dataset_id}.public_sykepengesoknad_id` a
  INNER JOIN `${var.gcp_project["project"]}.${google_bigquery_dataset.sak_status_metrikk_datastream.dataset_id}.public_sykepengesoknad_vedtaksperiode` b ON b.sykepengesoknad_at_id = a.sykepengesoknad_at_id
  INNER JOIN `${var.gcp_project["project"]}.${google_bigquery_dataset.sak_status_metrikk_datastream.dataset_id}.public_vedtaksperiode_tilstand` c on c.vedtaksperiode_id = b.vedtaksperiode_id
  INNER JOIN (
    SELECT vedtaksperiode_id, max(tidspunkt) AS tidspunkt
    FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.sak_status_metrikk_datastream.dataset_id}.public_vedtaksperiode_tilstand`
    GROUP BY vedtaksperiode_id
  ) d ON c.vedtaksperiode_id = d.vedtaksperiode_id AND d.tidspunkt = c.tidspunkt
  LEFT OUTER JOIN (SELECT vedtaksperiode_id,
                         string_agg(distinct melding, "," order by melding) funksjonell_feil
                   FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.sak_status_metrikk_datastream.dataset_id}.public_vedtaksperiode_funksjonell_feil`
                   group by vedtaksperiode_id) f on f.vedtaksperiode_id = b.vedtaksperiode_id
  LEFT OUTER JOIN (SELECT vedtaksperiode_id, true forkastet
                   FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.sak_status_metrikk_datastream.dataset_id}.public_vedtaksperiode_forkastet`
                   group by vedtaksperiode_id) t on t.vedtaksperiode_id = b.vedtaksperiode_id
EOF

}