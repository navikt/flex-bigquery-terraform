# flex-biqquery-terraform

Terraform-konfigurasjon for å flytte data fra [Google Cloud SQL](https://cloud.google.com/sql) databaser til [Google BigQuery](https://cloud.google.com/bigquery) med [Google Datastream (Change Data Capture)](https://cloud.google.com/datastream).

Repoet er spesifikk for Team Flex i NAV PO Helse, men har flere [moduler](https://github.com/navikt/flex-bigquery-terraform/tree/main/modules) som kan gjenbrukes utenfor NAV med ingen eller mindre modifikasjoner.

Bakgrunnen for oppsettet er at Team Flex ønsker å kunne bruke BigQuery som datakilde for analyse, visualisering og overvåkning av dataintegritet på tvers av databaser.

Datastream er valgt på grunn av at data blir oppdatert så fort de blir skrevet til eller endret i kildedatabasen. Alternativet er
[federated queries](https://cloud.google.com/bigquery/docs/cloud-sql-federated-queries), som typisk flytter data definert i en SQL-spørring ved angitte intervaller.

Begrunnelsen for bruk av Terraform er todelt. Først og fremst
gir det teamet en deterministisk måte å opprette og slette ressurser på. For det andre fungerer konfigurasjonen fungerer som
dokumentasjon på hvilke ressurser som er opprettet.

Et annet alternativ er [nada-datasteram](https://github.com/navikt/nada-datastream), som gjør samme nytte men med en annen tilnærming.
