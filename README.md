# flex-biqquery-terraform

Terraform-konfigurasjon for å flytte data fra [Google Cloud SQL](https://cloud.google.com/sql) databaser til [Google BigQuery](https://cloud.google.com/bigquery) med [Google Datastream (Change Data Capture)](https://cloud.google.com/datastream).

Repoet er spesifikk for Team Flex i NAV PO Helse, men har flere [moduler](https://github.com/navikt/flex-bigquery-terraform/tree/main/modules) som kan gjenbrukes utenfor NAV med ingen eller mindre modifikasjoner.

Bakgrunnen for oppsettet er at Team Flex ønsker å kunne bruke BigQuery som datakilde for analyse, visualisering og overvåkning av dataintegritet på tvers av databaser.

Datastream er valgt på grunn av at data blir streamet til BigQuery så fort de blir skrevet til eller endret i kildedatabasen. Alternativet er
[federated queries](https://cloud.google.com/bigquery/docs/cloud-sql-federated-queries), som typisk flytter data definert i en SQL-spørring ved angitte intervaller.

Begrunnelsen for bruk av Terraform er todelt. Først og fremst gir det teamet en deterministisk måte å opprette og slette ressurser på. For det andre fungerer konfigurasjonen fungerer som dokumentasjon på hvilke ressurser som er opprettet.

Et alternativ til dette er [nada-datasteram](https://github.com/navikt/nada-datastream), som gjør samme nytte men med en annen tilnærming.

## Arkitektur

![Arkitektur](./dokumentasjon/bilder/arkitektur.png)

## Kommandoer

Eksemplene bruker ressurser relatert til `spinnsyn-datastream` som eksempel.

List Datastreams med tilhørende status:

```sh
gcloud datastream streams list --location=europe-north1 --project=flex-prod-af40 | tr -s ' ' | cut -d ' '  -f1,2
```

Stopp en Datastream:

```sh
gcloud datastream streams update spinnsyn-datastream  --project=flex-prod-af40  --location=europe-north1 --update-mask=state --state=PAUSED
```

Start en Datastream:

```sh
gcloud datastream streams update spinnsyn-datastream  --project=flex-prod-af40  --location=europe-north1 --update-mask=state --state=STARTED
```

Hvis en Datastream stopper opp _kan_ det være fordi VM-instansen som kjører Cloud SQL AUth Proxy for den aktuelle applikasjonen trenger å resettes. Det skjer gjerne hvis maskinen har for lite minne. Datastreamen vil starte igjen av seg selv etter en reset.

```sh
gcloud compute instances reset spinnsyn-cloud-sql-auth-proxy --zone=europe-north1-a --flex-prod-af40
```

Slett BigQuery tabell:

```sh
bq rm -t flex-prod-af40:spinnsyn_datastream.public_utbetaling
```

## BigQuery Clustering

_Partitioning_ er når en tabell deles inn i mindre deler basert på en bestemt kolonne, vanligvis en tidskolonne. Dette forbedrer ytelsen og redusere kostnader ved spørringer, da bare relevante partisjoner blir skannet i stedet for hele tabellen.

 _Clustering_ i BigQuery er når dataene innenfor en partisjon sorteres basert på en eller flere kolonner for å ytterlligere forbedrer ytelsen.

Datastreams oppretter automatisk tabeller, men kan også skrive til ekisterende tabeller. Hvis man vil skrive til en BigQuery-tabeller som er clustret eller partisjonert må tabellen opprettes separat. Se Terraform-ressursen [google_bigquery_table](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table).
