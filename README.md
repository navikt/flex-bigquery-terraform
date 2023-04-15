# flex-biqquery-terraform

Terraform scripts for opprettelse av BigQuery ressurser for Team Flex.

## Partisjonering DDL

### spinnsyn.utbetaling

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
  DATE_TRUNC(opprettet,MONTH)
CLUSTER BY
  id, fnr, lest OPTIONS(max_staleness=INTERVAL 15 MINUTE);
```

### spinnsyn.annullering

```sql
CREATE TABLE `flex-dev-2b16.spinnsyn_datastream.public_annullering` (
  id STRING(36),
  fnr STRING(11),
  annullering JSON,
  opprettet TIMESTAMP,
  datastream_metadata STRUCT<uuid STRING, source_timestamp INT64>,
  PRIMARY KEY (id) NOT ENFORCED
)
PARTITION BY
  DATE_TRUNC(opprettet,MONTH)
CLUSTER BY
  id, fnr OPTIONS(max_staleness=INTERVAL 15 MINUTE);
```