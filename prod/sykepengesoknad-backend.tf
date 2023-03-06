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
module "sykepengesoknad_sykepengesoknad_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykepengesoknad_sykepengesoknad_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "id"
        type        = "STRING"
        description = "Database ID for sykepengesøknaden."
      },
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
        name        = "fom"
        type        = "DATE"
        description = "Første dag i perioden sykepengesøknaden er for."
      },
      {
        mode        = "NULLABLE"
        name        = "tom"
        type        = "DATE"
        description = "Siste dag i perioden sykepengesøknaden er for."
      },
      {
        mode        = "NULLABLE"
        name        = "sykmelding_uuid"
        type        = "STRING"
        description = "Unik ID for sykmeldingen som ligger til grunn for sykepengesøknaden."
      },
      {
        mode        = "NULLABLE"
        name        = "aktivert_dato"
        type        = "DATE"
        description = "Når sykepengesøknden ble aktivert."
      },
      {
        mode        = "NULLABLE"
        name        = "korrigerer"
        type        = "STRING"
        description = "Unik ID til en sykepengesøknad denne søknaden korrigerer."
      },
      {
        mode        = "NULLABLE"
        name        = "korrigert_av"
        type        = "STRING"
        description = "Unik ID til en sykepengesøknad som korrigerer denne søknaden."
      },
      {
        mode        = "NULLABLE"
        name        = "avbrutt_dato"
        type        = "DATE"
        description = "Dato for en eventuell avbrytelse av søknaden."
      },
      {
        mode        = "NULLABLE"
        name        = "arbeidssituasjon"
        type        = "STRING"
        description = "Hvilken arbeidssituason søknaden er for."
      },
      {
        mode        = "NULLABLE"
        name        = "start_sykeforlop"
        type        = "DATE"
        description = "Første dag i sykeforløpet som sykepengesøknaden er en del av."
      },
      {
        mode        = "NULLABLE"
        name        = "arbeidsgiver_orgnummer"
        type        = "STRING"
        description = "Arbeidsgivers organisasjonsnummer."
      },
      {
        mode        = "NULLABLE"
        name        = "arbeidsgiver_navn"
        type        = "STRING"
        description = "Arbeidsgivers navn."
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
        name        = "sykmelding_skrevet"
        type        = "TIMESTAMP"
        description = "Når sykmeldingen som ligger til grunn for sykepengesøknaden ble skrevet."
      },
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når sykepengesøknaden ble opprettet."
      },
      {
        mode        = "NULLABLE"
        name        = "opprinnelse"
        type        = "STRING"
        description = "Sykepengesøknadens systemopprinnelse."
      },
      {
        mode        = "NULLABLE"
        name        = "avsendertype"
        type        = "STRING"
        description = "Om avsender er BRUKER eller SYSTEM."
      },
      {
        mode        = "NULLABLE"
        name        = "egenmeldt_sykmelding"
        type        = "BOOLEAN"
        description = "Om søknaden er egenmeldt (koronarelatert)."
      },
      {
        mode        = "NULLABLE"
        name        = "merknader_fra_sykmelding"
        type        = "STRING"
        description = "Merknader hentet fra sykmeldingen."
      },
      {
        mode        = "NULLABLE"
        name        = "utlopt_publisert"
        type        = "TIMESTAMP"
        description = "Når det ble publisert en utløpt melding."
      },
      {
        mode        = "NULLABLE"
        name        = "avbrutt_feilinfo"
        type        = "BOOLEAN"
        description = "Om bruker fikk feil avbrutt-info presentert. Styrer tekst i Gosys-oppgave."
      },
      {
        mode        = "NULLABLE"
        name        = "sendt"
        type        = "TIMESTAMP"
        description = "Tidspunkt når søknaden først ble sendt til NAV, Arbeidsgiver eller begge."
      },
      {
        mode        = "NULLABLE"
        name        = "utenlandsk_sykmelding"
        type        = "BOOLEAN"
        description = "Om sykmeldingen er en utenlandssykemelding eller ikke."
      }
    ]
  )

  view_query = <<EOF
SELECT id, sykepengesoknad_uuid, soknadstype, status, fom, tom, sykmelding_uuid, aktivert_dato, korrigerer, korrigert_av, avbrutt_dato, arbeidssituasjon, start_sykeforlop, TO_HEX(MD5(arbeidsgiver_orgnummer)) AS arbeidsgiver_orgnummer, arbeidsgiver_navn, sendt_arbeidsgiver, sendt_nav, sykmelding_skrevet, opprettet, opprinnelse, avsendertype, egenmeldt_sykmelding, merknader_fra_sykmelding, utlopt_publisert, avbrutt_feilinfo, sendt, utenlandsk_sykmelding
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sykepengesoknad.bigquery_table_id}`
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

module "sykepengesoknad_hovedsporsmal_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykepengesoknad_hovedsporsmal_view"
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
        name        = "fom"
        type        = "DATE"
        description = "Første dag i perioden sykepengesøknaden er for."
      },
      {
        mode        = "NULLABLE"
        name        = "tom"
        type        = "DATE"
        description = "Siste dag i perioden sykepengesøknaden er for."
      },
      {
        mode        = "NULLABLE"
        name        = "opprettet"
        type        = "TIMESTAMP"
        description = "Når sykepengesøknaden ble opprettet."
      },
      {
        mode        = "NULLABLE"
        name        = "sendt"
        type        = "TIMESTAMP"
        description = "Tidspunkt når søknaden først ble sendt til NAV, Arbeidsgiver eller begge."
      },
      {
        mode        = "NULLABLE"
        name        = "status"
        type        = "STRING"
        description = "Sykepengesøknadens status."
      },
      {
        mode        = "NULLABLE"
        name        = "korrigerer"
        type        = "STRING"
        description = "ID til søknaden den aktuelle søknaden korrigerer."
      },
      {
        mode        = "NULLABLE"
        name        = "soknadstype"
        type        = "STRING"
        description = "Hvilken type sykepengesøknaden er."
      },
      {
        mode        = "NULLABLE"
        name        = "sporsmal_tag"
        type        = "STRING"
        description = "Hvilket spørsmål det dreier seg om."
      },
      {
        mode        = "NULLABLE"
        name        = "verdi"
        type        = "STRING"
        description = "Svaret på det aktuelle spørsmålet."
      },
    ]
  )

  view_query = <<EOF
SELECT
  sykepengesoknad.sykepengesoknad_uuid,
  sykepengesoknad.fom,
  sykepengesoknad.tom,
  sykepengesoknad.opprettet,
  sykepengesoknad.sendt,
  sykepengesoknad.status,
  sykepengesoknad.korrigerer,
  soknadstype,
  sporsmal.tag AS sporsmal_tag,
  svar.verdi
FROM
  `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sykepengesoknad.bigquery_table_id}` sykepengesoknad
INNER JOIN
  `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sporsmal.bigquery_table_id}` sporsmal
ON
  sporsmal.sykepengesoknad_id = sykepengesoknad.id
INNER JOIN
  `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_svar.bigquery_table_id}` svar
ON
  svar.sporsmal_id = sporsmal.id
WHERE sporsmal.svartype = 'JA_NEI'
  AND sporsmal.under_sporsmal_id IS NULL
  AND sykepengesoknad.status IN ('SENDT', 'KORRIGERT')
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

module "sykepengesoknad_klipp_metrikk_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykepengesoknad_klipp_metrikk_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "id"
        type        = "STRING"
        description = "Unik ID i tabellen."
      },
      {
        mode        = "NULLABLE"
        name        = "sykmelding_uuid"
        type        = "STRING"
        description = "ID for sykmeldingen som overlappet med en søknad."
      },
      {
        mode        = "NULLABLE"
        name        = "variant"
        type        = "STRING"
        description = "Varianten av klipp som kunne skje."
      },
      {
        mode        = "NULLABLE"
        name        = "soknadstatus"
        type        = "STRING"
        description = "Status på søknad som ligger i databasen."
      },
      {
        mode        = "NULLABLE"
        name        = "timestamp"
        type        = "TIMESTAMP"
        description = "Tidspunktet sykmeldingen som overlappet kom inn."
      },
      {
        mode        = "NULLABLE"
        name        = "eksisterende_sykepengesoknad_id"
        type        = "STRING"
        description = "ID på sykepengesøknad som eksisterte når overlappet kom inn."
      },
      {
        mode        = "NULLABLE"
        name        = "endring_i_uforegrad"
        type        = "STRING"
        description = "Endring i uføregrad for den overlappend perioden."
      },
      {
        mode        = "NULLABLE"
        name        = "klippet"
        type        = "BOOLEAN"
        description = "Om søknaden ble klippet eller ikke."
      }
    ]
  )

  view_query = <<EOF
SELECT id, sykmelding_uuid, variant, soknadstatus, timestamp, eksisterende_sykepengesoknad_id, endring_i_uforegrad, klippet
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_klipp_metrikk.bigquery_table_id}`
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

module "sykepengesoknad_hovedsporsmal_pivot_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykepengesoknad_hovedsporsmal_pivot_view"
  view_schema = jsonencode(
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

  view_query = <<EOF
SELECT *
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_hovedsporsmal_pivot.bigquery_table_id}`
EOF

}

module "sykepengesoknad_andre_inntektskilder_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykepengesoknad_andre_inntektskilder_view"
  view_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_uuid"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "sendt"
        type = "TIMESTAMP"
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
        name = "status"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "tag"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "svar"
        type = "BOOLEAN"
      }
    ]
  )

  view_query = <<EOF
WITH ja_hovedspm AS (SELECT sporsmal.id
                     FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sporsmal.bigquery_table_id}` sporsmal
                              INNER JOIN
                          `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_svar.bigquery_table_id}` svar
                          ON
                              svar.sporsmal_id = sporsmal.id
                     WHERE svar.verdi = 'JA'
                       AND sporsmal.tag = "ANDRE_INNTEKTSKILDER_V2"),

     ja_hovedspm_gruppen AS (SELECT sporsmal.id
                             FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sporsmal.bigquery_table_id}` sporsmal,
                                  ja_hovedspm
                             WHERE under_sporsmal_id = ja_hovedspm.id),

     checkboxider AS (SELECT sporsmal.id, sporsmal.tag, sporsmal.sykepengesoknad_id
                      FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sporsmal.bigquery_table_id}` sporsmal,
                           ja_hovedspm_gruppen
                      WHERE under_sporsmal_id = ja_hovedspm_gruppen.id),

     checkboxmedsvar AS (SELECT checkboxider.*, svar.verdi
                         FROM checkboxider
                                  left outer join `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_svar.bigquery_table_id}` svar
                                                  on checkboxider.id = svar.sporsmal_id)

SELECT soknad.sykepengesoknad_uuid,
       soknad.sendt,
       soknad.korrigerer,
       soknad.korrigert_av,
       soknad.status,
       checkboxmedsvar.tag,
       CASE verdi
           WHEN "CHECKED" THEN true
           ELSE false
           END
           AS svar
FROM checkboxmedsvar
         INNER JOIN `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sykepengesoknad.bigquery_table_id}` soknad
                    on checkboxmedsvar.sykepengesoknad_id = soknad.id
EOF

}

module "korrigerte_sporsmal_tilstand_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "korrigerte_sporsmal_tilstand_view"
  view_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_uuid"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "opprettet"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "korrigeringSendt"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "opprinneligSendt"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "endring"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "tag"
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
        name = "hovedsvar"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "tilstand"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "tidspunkt"
        type = "TIMESTAMP"
      },
      {
        mode = "NULLABLE"
        name = "funksjonell_feil"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "forkastet"
        type = "BOOLEAN"
      }
    ]
  )

  view_query = <<EOF
SELECT stv.sykepengesoknad_uuid,
       ks.opprettet,
       ks.korrigeringSendt,
       ks.opprinneligSendt,
       ks.endring,
       ks.tag,
       ks.fom,
       ks.tom,
       ks.hovedsvar,
       stv.tilstand,
       stv.tidspunkt,
       stv.funksjonell_feil,
       stv.forkastet
FROM `${var.gcp_project["project"]}.korrigering_metrikk.korrigerte_sporsmal` ks,
     `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sak_status_metrikk_siste_tilstand_view.bigquery_view_id}` stv
where ks.sykepengesoknadId = stv.sykepengesoknad_uuid
EOF

}