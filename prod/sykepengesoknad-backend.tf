data "google_secret_manager_secret_version" "sykepengesoknad_bigquery_secret" {
  secret = var.sykepengesoknad_bigquery_secret
}

locals {
  sykepengesoknad_db = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_bigquery_secret.secret_data
  )
}

module "sykepengesoknad_bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-backend"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad"
  database      = "sykepengesoknad"
  username      = local.sykepengesoknad_db.username
  password      = local.sykepengesoknad_db.password
}



module "sykepengesoknad_sykepengesoknad" {
  source = "../modules/google-bigquery-table"

  location   = var.gcp_project["region"]
  dataset_id = module.flex_dataset.dataset_id
  table_id   = "sykepengesoknad"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_uuid"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "soknadstype"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "status"
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
        name = "sykmelding_uuid"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "aktivert_dato"
        type = "DATE"
      },
      {
        mode = "NULLABLE"
        name = "korrigerer"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "korrigert_av"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "avbrutt_dato"
        type = "DATE"
      },
      {
        mode = "NULLABLE"
        name = "arbeidssituasjon"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "start_sykeforlop"
        type = "DATE"
      },
      {
        mode = "NULLABLE"
        name = "arbeidsgiver_orgnummer"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "arbeidsgiver_navn"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "sendt_arbeidsgiver"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "sendt_nav"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "sykmelding_skrevet"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "opprettet"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "opprinnelse"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "avsendertype"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "fnr"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "egenmeldt_sykmelding"
        type = "BOOL"
      },
      {
        mode = "NULLABLE"
        name = "merknader_fra_sykmelding"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "utlopt_publisert"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "avbrutt_feilinfo"
        type = "BOOL"
      }
    ]
  )

  view_id = "sykepengesoknad_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "id"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_uuid"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "soknadstype"
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
        name        = "fom"
        type        = "DATE"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "tom"
        type        = "DATE"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "sykmelding_uuid"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "aktivert_dato"
        type        = "DATE"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "korrigerer"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "korrigert_av"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "avbrutt_dato"
        type        = "DATE"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "arbeidssituasjon"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "start_sykeforlop"
        type        = "DATE"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "arbeidsgiver_orgnummer"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "arbeidsgiver_navn"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "sendt_arbeidsgiver"
        type        = "TIMESTAMP"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "sendt_nav"
        type        = "TIMESTAMP"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "sykmelding_skrevet"
        type        = "TIMESTAMP"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "opprinnelse"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "avsendertype"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "egenmeldt_sykmelding"
        type        = "BOOL"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "merknader_fra_sykmelding"
        type        = "STRING"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "utlopt_publisert"
        type        = "TIMESTAMP"
        description = ""
      },
      {
        mode        = "NULLABLE"
        name        = "avbrutt_feilinfo"
        type        = "BOOL"
        description = ""
      }
    ]
  )

  view_query = <<EOF
SELECT id, sykepengesoknad_uuid, soknadstype, status, fom, tom, sykmelding_uuid, aktivert_dato, korrigerer, korrigert_av, avbrutt_dato, arbeidssituasjon, start_sykeforlop, arbeidsgiver_orgnummer, arbeidsgiver_navn, sendt_arbeidsgiver, sendt_nav, sykmelding_skrevet, opprettet, opprinnelse, avsendertype, egenmeldt_sykmelding, merknader_fra_sykmelding, utlopt_publisert, avbrutt_feilinfo
FROM `${var.gcp_project["project"]}.${module.flex_dataset.dataset_id}.${module.sykepengesoknad_sykepengesoknad.bigquery_table_id}`
EOF

  data_transfer_display_name      = "sykepengesoknad_sykepengesoknad_query"
  data_transfer_schedule          = "every day 03:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2022-11-28T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_sykepengesoknad.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-backend',
'SELECT id, sykepengesoknad_uuid, soknadstype, status, fom, tom, sykmelding_uuid, aktivert_dato, korrigerer, korrigert_av, avbrutt_dato, arbeidssituasjon, start_sykeforlop, arbeidsgiver_orgnummer, arbeidsgiver_navn, sendt_arbeidsgiver, sendt_nav, sykmelding_skrevet, opprettet, opprinnelse, avsendertype, fnr, egenmeldt_sykmelding, merknader_fra_sykmelding, utlopt_publisert, avbrutt_feilinfo FROM sykepengesoknad');
EOF

}