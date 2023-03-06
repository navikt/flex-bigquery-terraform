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

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_sykepengesoknad"
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
        type = "BOOLEAN"
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
        type = "BOOLEAN"
      },
      {
        mode = "NULLABLE"
        name = "sendt"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "utenlandsk_sykmelding"
        type = "BOOLEAN"
      }
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_sykepengesoknad_query"
  data_transfer_schedule          = "every day 05:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-02-15T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_sykepengesoknad.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-backend',
'SELECT id, sykepengesoknad_uuid, soknadstype, status, fom, tom, sykmelding_uuid, aktivert_dato, korrigerer, korrigert_av, avbrutt_dato, arbeidssituasjon, start_sykeforlop, arbeidsgiver_orgnummer, arbeidsgiver_navn, sendt_arbeidsgiver, sendt_nav, sykmelding_skrevet, opprettet, opprinnelse, avsendertype, fnr, egenmeldt_sykmelding, merknader_fra_sykmelding, utlopt_publisert, avbrutt_feilinfo, sendt, utenlandsk_sykmelding FROM sykepengesoknad');
EOF

}

module "sykepengesoknad_sporsmal" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_sporsmal"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "under_sporsmal_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "tekst"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "undertekst"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "tag"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "svartype"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "min"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "max"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "kriterie_for_visning"
        type = "STRING"
      }
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_sporsmal_query"
  data_transfer_schedule          = "every day 04:10"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-02-15T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_sporsmal.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-backend',
'SELECT id, sykepengesoknad_id, under_sporsmal_id, tekst, undertekst, tag, svartype, min, max, kriterie_for_visning FROM sporsmal');
EOF

}

module "sykepengesoknad_svar" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_svar"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "sporsmal_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "verdi"
        type = "STRING"
      }
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_svar_query"
  data_transfer_schedule          = "every day 05:20"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-02-15T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_svar.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-backend',
'SELECT id, sporsmal_id, verdi FROM svar');
EOF

}

module "sykepengesoknad_klipp_metrikk" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_klipp_metrikk"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "sykmelding_uuid"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "variant"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "soknadstatus"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "timestamp"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "eksisterende_sykepengesoknad_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "endring_i_uforegrad"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "klippet"
        type = "BOOLEAN"
      }
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_klipp_metrikk_query"
  data_transfer_schedule          = "every day 05:10"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-02-15T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_klipp_metrikk.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-backend',
'SELECT id, sykmelding_uuid, variant, soknadstatus, timestamp, eksisterende_sykepengesoknad_id, endring_i_uforegrad, klippet FROM klipp_metrikk');
EOF

}

module "sykepengesoknad_soknadperiode" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_soknadperiode"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_id"
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
        name = "grad"
        type = "INT64"
      },
      {
        mode = "NULLABLE"
        name = "sykmeldingstype"
        type = "STRING"
      }
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_soknadperiode_query"
  data_transfer_schedule          = "every day 05:20"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-02-15T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_soknadperiode.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-backend',
'SELECT sykepengesoknad_id, fom, tom, grad, sykmeldingstype FROM soknadperiode');
EOF

}

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