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
  data_transfer_start_time        = "2022-12-08T00:00:00Z"
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
  data_transfer_start_time        = "2022-12-08T00:00:00Z"
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
  data_transfer_start_time        = "2022-12-08T00:00:00Z"
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

module "sykepengesoknad_klippet_sykepengesoknad" {
  source = "../modules/google-bigquery-table"

  location   = var.gcp_project["region"]
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "sykepengesoknad_klippet_sykepengesoknad"
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
        name = "sykmelding_uuid"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "klipp_variant"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "periode_for"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "periode_etter"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "timestamp"
        type = "TIMESTAMP"
      }
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_klippet_sykepengesoknad_query"
  data_transfer_schedule          = "every day 05:10"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2022-12-08T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_klippet_sykepengesoknad.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-backend',
'SELECT id, sykepengesoknad_uuid, sykmelding_uuid, klipp_variant, periode_for, periode_etter, timestamp FROM klippet_sykepengesoknad');
EOF

}

module "sykepengesoknad_klippet_sykepengesoknad_view" {
  source = "../modules/google-bigquery-view"

  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  view_id    = "sykepengesoknad_klippet_sykepengesoknad_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "id"
        type        = "STRING"
        description = "Unik ID for en klippet søknad eller sykmelding."
      },
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_uuid"
        type        = "STRING"
        description = "ID for søknaden som overlappet med en sykmelding."
      },
      {
        mode        = "NULLABLE"
        name        = "sykmelding_uuid"
        type        = "STRING"
        description = "ID for sykmeldingen som overlappet med en søknad."
      },
      {
        mode        = "NULLABLE"
        name        = "klipp_variant"
        type        = "STRING"
        description = "Varianten av klipp som sier om det er en søknad eller sykmelding som ble klippet og hvilke del som var overlappende."
      },
      {
        mode        = "NULLABLE"
        name        = "timestamp"
        type        = "TIMESTAMP"
        description = "Tidspunktet klippen skjedde."
      },
    ]
  )

  view_query = <<EOF
SELECT id, sykepengesoknad_uuid, sykmelding_uuid, klipp_variant, timestamp
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_klippet_sykepengesoknad.bigquery_table_id}`
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
        name = "EKSISTERENDE_SYKEPENGESOKNAD_ID"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "ENDRING_I_UFOREGRAD"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "KLIPPET"
        type = "BOOLEAN"
      }
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_klipp_metrikk_query"
  data_transfer_schedule          = "every day 05:10"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-01-05T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_klipp_metrikk.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-backend',
'SELECT id, sykmelding_uuid, variant, soknadstatus, timestamp FROM klipp_metrikk');
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

  view_query = <<EOF
SELECT id, sykmelding_uuid, variant, soknadstatus, timestamp, eksisterende_sykepengesoknad_id, endring_i_uforegrad, klippet
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_klipp_metrikk.bigquery_table_id}`
EOF

}

module "sykepengesoknad_soknadperiode" {
  source = "../modules/google-bigquery-table"

  location   = var.gcp_project["region"]
  dataset_id = google_bigquery_dataset.flex_dataset.dataset_id
  table_id   = "sykepengesoknad_soknadperiode"
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
  data_transfer_start_time        = "2023-01-25T00:00:00Z"
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
        name = "verdi"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "sporsmal_tag"
        type = "STRING"
      }
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_hovedsporsmal_pivot_query"
  data_transfer_schedule          = "every day 06:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-02-07T00:00:00Z"
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
      FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.sykepengesoknad_hovedsporsmal_view`) PIVOT
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
