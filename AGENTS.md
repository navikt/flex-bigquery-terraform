# AGENTS.md

This file gives instructions to agents that work with code in this repository.

## Overview

This repository holds the Terraform config for team Flex in Nav. It moves data
from Cloud SQL databases to BigQuery with Google Datastream. It also creates
BigQuery datasets, views and monitoring. The `README.md` and the files in
`dokumentasjon/` are in Norwegian.

## Structure

- `dev/` and `prod/`: Two separate Terraform root configs. Each one creates
  resources in its own GCP project (`flex-dev-2b16` and `flex-prod-af40`).
- `terraform.tfvars`: Shared variable values for both root configs.
- `modules/`: Local modules for BigQuery connections, tables and views, Cloud
  Storage and monitoring.
- `dokumentasjon/`: Architecture diagram and the IAM runbook.

Each root config splits resources across files:

- `main.tf`: Shared resources, provider and the GCS backend.
- `variables.tf`: Input variables and default values.
- `secrets.tf`: `data` resources that read from Google Secret Manager.
- `datastream-vpc.tf`: VPC resources that all datastreams share.
- `datastreams.tf`: One module instance for each datastream.
- `flex-dataset.tf`: The `flex_dataset` with access control. Its views are
  data products on Datamarkedsplassen.
- `soda-dataset.tf`: The `soda_dataset` with views for `flex-bigquery-soda`.
- `external-connection.tf`: Connections from BigQuery to Cloud SQL.
- `tabeller-<application>.tf`: Tables in `flex_dataset` for one application.
- `views-<application>.tf`: Views in `flex_dataset` for one application.

## Commands

Run the commands in `dev/` or `prod/`:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file=../terraform.tfvars
```

To run Terraform locally, authenticate first with `nais login` or
`gcloud auth login --update-adc`.

## CI

`.github/workflows/terraform.yml` runs on every push:

1. It runs `fmt -check`, `validate` and `plan` for `dev` and `prod`.
2. On `main`, it runs `apply` for `dev` and `prod`.
3. On branches with the prefix `dev-`, it runs `apply` for `dev` only.

GitHub Actions authenticates with Workload Identity Federation. See
`dokumentasjon/iam-runbook.md` for the IAM setup.

## Rules

- Do not run `terraform apply` locally unless the user asks for it. CI applies
  all changes.
- When you add a resource to `prod/`, check if `dev/` needs the same resource.
  `dev/` has fewer resources than `prod/`, so not all resources belong there.
- Datastreams use the external module `terraform-google-bigquery-datastream`
  with a pinned `ref` tag. To change the module, change it in its own
  repository, create a tag, and then update `ref` in `datastreams.tf`.
- When you change or delete a view in `soda_dataset`, update the contracts in
  `flex-bigquery-soda`.

## Glossary

- **Root config**: A folder (`dev/` or `prod/`) where you run Terraform
  commands. Each root config has its own state.
- **flex_dataset**: The BigQuery dataset with data products for other teams.
- **soda_dataset**: The BigQuery dataset with views that Soda checks read.
- **Datamarkedsplassen**: Nav's internal data catalogue.
- **Tabeller**: Norwegian for tables.
