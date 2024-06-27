module "inntektsmelding_status_event_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "inntektsmelding_status_event_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Tidspunkt for eventet."
      },
      {
        mode        = "NULLABLE"
        name        = "status"
        type        = "STRING"
        description = "status på eventet"
      }
    ]
  )
  view_query = <<EOF
SELECT opprettet, status
FROM `${var.gcp_project["project"]}.${module.inntektsmelding_status_datastream.dataset_id}.public_inntektsmelding_status`
EOF

}

module "venter_pa_arbeidsgiver_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "venter_pa_arbeidsgiver_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_uuid"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "sendt"
        type        = "TIMESTAMP"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "dager_siden_sendt"
        type        = "INTEGER"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "siste_varslingstatus"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "siste_varslingstatus_tidspunkt"
        type        = "TIMESTAMP"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "dager_siden_siste_varslingstatus_tidspunkt"
        type        = "INTEGER"
        description = ""
      }
    ]
  )
  view_query = <<EOF
select max(s.sykepengesoknad_uuid)                                         as sykepengesoknad_uuid,
       max(s.sendt)                                                        as sendt,
       DATE_DIFF(CAST(CURRENT_DATE() AS TIMESTAMP), MAX(s.sendt), DAY) + 1 AS dager_siden_sendt,
       max(v.siste_varslingstatus)                                            siste_varslingstatus,
       max(v.siste_varslingstatus_tidspunkt)                                  siste_varslingstatus_tidspunkt,
       DATE_DIFF(CAST(CURRENT_DATE() AS TIMESTAMP), MAX(v.siste_varslingstatus_tidspunkt), DAY) + 1 AS dager_siden_siste_varslingstatus_tidspunkt
FROM `${var.gcp_project["project"]}.${module.inntektsmelding_status_datastream.dataset_id}.public_vedtaksperiode_behandling` v, `${var.gcp_project["project"]}.${module.inntektsmelding_status_datastream.dataset_id}..public_sykepengesoknad` s, `${var.gcp_project["project"]}.${module.inntektsmelding_status_datastream.dataset_id}..public_vedtaksperiode_behandling_sykepengesoknad` vbs
WHERE vbs.sykepengesoknad_uuid = s.sykepengesoknad_uuid
  AND vbs.vedtaksperiode_behandling_id = v.id
  AND v.siste_spleisstatus = 'VENTER_PÅ_ARBEIDSGIVER'
group by v.vedtaksperiode_id, v.behandling_id
order by dager_siden_sendt desc
EOF

}


module "varsling_events_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "varsling_events_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "vedtaksperiode_id"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "behandling_id"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "status"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "tidspunkt"
        type        = "TIMESTAMP"
        description = ""
      }
    ]
  )
  view_query = <<EOF
SELECT vb.vedtaksperiode_id, vb.behandling_id, vbs.status, vbs.tidspunkt 
FROM `${var.gcp_project["project"]}.${module.inntektsmelding_status_datastream.dataset_id}.public_vedtaksperiode_behandling_status` vbs,
`${var.gcp_project["project"]}.${module.inntektsmelding_status_datastream.dataset_id}.public_vedtaksperiode_behandling`  vb
where vbs.vedtaksperiode_behandling_id = vb.id
EOF

}
