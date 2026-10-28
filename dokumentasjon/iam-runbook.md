# IAM-runbook for Terraform via GitHub WIF

Denne runbooken gir `navikt/flex-bigquery-terraform` alle tillatelsene nødvendig for Workload Identity Federation.

| Miljø | Prosjekt-ID | Prosjektnummer |
|---|---|---:|
| dev | `flex-dev-2b16` | `621342450460` |
| prod | `flex-prod-af40` | `1002409980618` |

## Komplett oppsett for dev

`--condition=None` unngår spørsmål når policyen allerede har betingede bindinger.

```sh
PROJECT_ID="flex-dev-2b16"
PROJECT_NUMBER="621342450460"
REPOSITORY="navikt/flex-bigquery-terraform"
PRINCIPAL="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-actions/attribute.repository/${REPOSITORY}"

for ROLE in \
  roles/compute.networkAdmin \
  roles/datastream.admin \
  roles/bigquery.dataOwner \
  roles/iam.serviceAccountAdmin \
  roles/resourcemanager.projectIamAdmin \
  roles/secretmanager.viewer \
  roles/secretmanager.secretAccessor \
  roles/cloudsql.viewer \
  roles/bigquery.connectionAdmin \
  roles/bigquery.jobUser \
  roles/monitoring.notificationChannelEditor \
  roles/bigquery.admin \
  roles/monitoring.alertPolicyEditor
do
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="${PRINCIPAL}" --role="${ROLE}" --condition=None --quiet
done

gcloud storage buckets add-iam-policy-binding gs://flex-terraform-state-dev --member="${PRINCIPAL}" --role="roles/storage.admin" --condition=None
gcloud storage buckets add-iam-policy-binding gs://flex-terraform-state-prod --member="${PRINCIPAL}" --role="roles/storage.objectAdmin" --condition=None  
```

## Komplett oppsett for prod

Bytt bucketnavnet hvis prod-backenden ikke heter `flex-terraform-state-prod`.

```sh
PROJECT_ID="flex-prod-af40"
PROJECT_NUMBER="1002409980618"
REPOSITORY="navikt/flex-bigquery-terraform"
PRINCIPAL="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-actions/attribute.repository/${REPOSITORY}"

for ROLE in \
  roles/compute.networkAdmin \
  roles/datastream.admin \
  roles/bigquery.dataOwner \
  roles/iam.serviceAccountAdmin \
  roles/resourcemanager.projectIamAdmin \
  roles/secretmanager.viewer \
  roles/secretmanager.secretAccessor \
  roles/cloudsql.viewer \
  roles/bigquery.connectionAdmin \
  roles/bigquery.jobUser \
  roles/monitoring.notificationChannelEditor \
  roles/bigquery.admin \
  roles/monitoring.alertPolicyEditor
do
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="${PRINCIPAL}" --role="${ROLE}" --condition=None --quiet
done

gcloud storage buckets add-iam-policy-binding gs://flex-terraform-state-prod --member="${PRINCIPAL}" --role="roles/storage.admin" --condition=None
gcloud storage buckets add-iam-policy-binding gs://flex-terraform-state-prod --member="${PRINCIPAL}" --role="roles/storage.objectAdmin" --condition=None  
```

## Repository

Tillater alle branches fra repositoryet.

```sh
gcloud iam workload-identity-pools providers update-oidc github-oidc \
  --project="${PROJECT_ID}" --location=global \
  --workload-identity-pool=github-actions \
  --attribute-condition="assertion.repository == 'navikt/flex-bigquery-terraform'"
```

## Verifisering

Verfiserer at roller for `dev` ikke finnes i `prod` og omvendt. 

```sh
for PROJECT_ID in flex-dev-2b16 flex-prod-af40
do
  gcloud projects get-iam-policy "${PROJECT_ID}" \
    --flatten="bindings[].members" \
    --filter="bindings.members:attribute.repository/navikt/flex-bigquery-terraform" \
    --format="table(bindings.role,bindings.members)"
done

gcloud storage buckets get-iam-policy gs://flex-terraform-state-dev
gcloud storage buckets get-iam-policy gs://flex-terraform-state-prod
```