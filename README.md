# flex-biqquery-terraform

Terraform-konfigurasjon for å flytte data fra applikasjonsspesifikke database i [Google Cloud SQL]() til [Google BigQuery]() 
med [Google Datastream]() for Team Flex.

Bakgrunnen for at data flyttes til BigQuery er et ønske om å kunne bruke BigQuery som datakilde for analyse og visualisering. 

Datastreams er valgt på grunn av at data blir oppdatert så fort de blir skrevet til eller endret i kildedatabasen. Alternativet er
[Federated Queries](), som typisk flytter data med angitte intervaller, basert på en SQL-spørring. For Team Flex sin del er 
dataene i kildedatabasen av en sånn art at vi ikke kan avgjøre hva som er nye eller nylig oppdatete data, og dermed må 
flytte alle data hver gang, noe som medfører flytt av unødveneidg mye data.
 

Begrunnelsen for å bruke Terraform i stedet for å opprettet ressursene direkte i [Cloud Console]() er todelt. Først og fremst 
gir det teamet en deterministisk måte å opprette og slette ressurser på. For det andre fungerer konfigurasjonen fungerer som 
dokumentasjon på hvlke ressurser som er opprettet.

## Clustering og Partisjonering

DDL for clustrering og partisjonering av enkelte tabeller.

Datastreams kan skrive til eksisterende tabeller, men det er per nå ikke mulig å opprettet partisjonerte tabeller med
Terraform. Tabeller som skal være partisjonert og clustred må dermed opprettes manuelt med følgende SQL:

### spinnsyn_datastream.public_utbetaling

```sql
CREATE TABLE `flex-prod-af40.spinnsyn_datastream.public_utbetaling` ( 
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

Tabell kan slettes med `bq rm -t flex-prod-af40:spinnsyn_datastream.public_utbetaling`.

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

Tabell kan slettes med `bq rm -t flex-prod-af40:sykepengesoknad_datastream.public_dodsmelding`.

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

Tabell kan slettes med `bq rm -t flex-prod-af40:sykepengesoknad_datastream.public_sykepengesoknad`.

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

Slett tabell med `bq rm -t flex-prod-af40:arkivering_oppgave_datastream.public_innsending`.

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

Tabell kan slettes med `bq rm -t flex-prod-af40:arkivering_oppgave_datastream.public_oppgavestyring`.
