# flex-biqquery-terraform

Terraform scripts for opprettelse av BigQuery ressurser for Team Flex.

## Partisjonering

DDL for clustrering og partisjonering av tabeller.

### spinnsyn_datastream.public_utbetaling

```sql
CREATE TABLE `flex-dev-2b16.spinnsyn_datastream.public_utbetaling` ( 
    id STRING(36),
    fnr STRING(11),
    utbetaling_id STRING(36),
    utbetaling_type STRING,
    utbetaling STRING,
    opprettet TIMESTAMP,
    antall_vedtak INT64,
    lest TIMESTAMP,
    motatt_publisert TIMESTAMP,
    skal_vises_til_bruker BOOL,
    datastream_metadata STRUCT<uuid STRING,
    source_timestamp INT64>,
    PRIMARY KEY (id) NOT ENFORCED
)
PARTITION BY
  DATE_TRUNC(opprettet, MONTH)
CLUSTER BY
  id, fnr OPTIONS(max_staleness=INTERVAL 15 MINUTE);
```

Slett tabell med `bq rm -t flex-dev-2b16.spinnsyn_datastream.public_utbetaling`.

### sykepengesoknad_datastream.public_dodsmelding

```sql
CREATE TABLE `flex-prod-af40.sykepengesoknad_datastream.public_dodsmelding`
(
    id STRING,
    fnr STRING(11),
    dodsdato DATE,
    melding_mottatt_dato TIMESTAMP,
    datastream_metadata STRUCT<uuid STRING, source_timestamp INT64>,
    PRIMARY KEY (id) NOT ENFORCED
)
PARTITION BY
  DATE_TRUNC(melding_mottatt_dato, MONTH)
CLUSTER BY
  fnr OPTIONS(max_staleness=INTERVAL 15 MINUTE);
```

Slett tabell med `bq rm -t flex-prod-af40.sykepengesoknad_datastream.public_dodsmelding`.

### sykepengesoknad_datastream.public_sykepengesoknad

```sql
CREATE TABLE `flex-prod-af40.sykepengesoknad_datastream.public_sykepengesoknad`
(
    id STRING,
    sykepengesoknad_uuid STRING,
    soknadstype STRING,
    status STRING,
    fom DATE,
    tom DATE,
    sykmelding_uuid STRING,
    aktivert_dato DATE,
    korrigerer STRING,
    korrigert_av STRING,
    avbrutt_dato DATE,
    arbeidssituasjon STRING,
    start_sykeforlop DATE,
    arbeidsgiver_orgnummer STRING,
    arbeidsgiver_navn STRING,
    sendt_arbeidsgiver TIMESTAMP,
    sendt_nav TIMESTAMP,
    sykmelding_skrevet TIMESTAMP,
    opprettet TIMESTAMP,
    opprinnelse STRING,
    avsendertype STRING,
    fnr STRING(11),
    egenmeldt_sykmelding BOOL,
    merknader_fra_sykmelding STRING,
    utlopt_publisert TIMESTAMP,
    avbrutt_feilinfo BOOL,
    opprettet_av_inntektsmelding BOOL,
    sendt TIMESTAMP,
    utenlandsk_sykmelding BOOL,
    datastream_metadata STRUCT<uuid STRING, source_timestamp INT64>,
    PRIMARY KEY (id) NOT ENFORCED
)
PARTITION BY
  DATE_TRUNC(opprettet, MONTH)
CLUSTER BY
  sykepengesoknad_uuid, status OPTIONS(max_staleness=INTERVAL 15 MINUTE);
```

Slett tabell med `bq rm -t flex-prod-af40.sykepengesoknad_datastream.public_sykepengesoknad`.

### arkivering_oppgave__datastream.public_innsending

```sql
CREATE TABLE `flex-prod-af40.arkivering_oppgave_datastream.public_innsending`
(
    id STRING(36),
    sykepengesoknad_id STRING(100),
    journalpost_id STRING(20),
    oppgave_id STRING(20),
    behandlet TIMESTAMP,
    datastream_metadata STRUCT<uuid STRING, source_timestamp INT64>,
    PRIMARY KEY (id) NOT ENFORCED
)
PARTITION BY
  DATE_TRUNC(behandlet, MONTH)
CLUSTER BY
  id OPTIONS(max_staleness=INTERVAL 15 MINUTE);
```

Slett tabell med `bq rm -t flex-prod-af40.arkivering_oppgave_datastream.public_innsending`.

### arkivering_oppgave_datastream.public_oppgavestyring

```sql
CREATE TABLE `flex-prod-af40.arkivering_oppgave_datastream.public_oppgavestyring`
(
    id STRING(36),
    sykepengesoknad_id STRING(100),
    status STRING(50),
    opprettet TIMESTAMP,
    modifisert TIMESTAMP,
    timeout TIMESTAMP,
    avstemt BOOL,
    datastream_metadata STRUCT<uuid STRING, source_timestamp INT64>,
    PRIMARY KEY (id) NOT ENFORCED
)
PARTITION BY
  DATE_TRUNC(opprettet, MONTH)
CLUSTER BY
  sykepengesoknad_id OPTIONS(max_staleness=INTERVAL 15 MINUTE);
```

Slett tabell med `bq rm -t flex-prod-af40.arkivering_oppgave_datastream.public_oppgavestyring`.
