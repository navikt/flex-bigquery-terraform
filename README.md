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