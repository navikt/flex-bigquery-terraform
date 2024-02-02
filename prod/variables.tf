variable "gcp_project" {
  description = "GCP project and region defaults."
  type        = map(string)
  default = {
    region  = "europe-north1",
    zone    = "europe-north1-a",
    project = "flex-prod-af40"
  }
}

variable "metabase_service_account" {
  description = "The Metabase Service Account used when accessing data. Must have access to tablers underlying vies."
  type        = string
  default     = "nada-metabase@nada-prod-6977.iam.gserviceaccount.com"
}

variable "scheduled_query_data_source_id" {
  description = "The documentation states that this value can be changed, but any other value causes a failure."
  type        = string
  default     = "scheduled_query"
}

variable "spinnsyn_bigquery_secret" {
  description = "The key of the GCP secret that provides the spinnsyn database credentials."
  type        = string
  default     = "spinnsyn-bigquery-credentials"
}

variable "spinnsyn_datastream_secret" {
  description = "The key of the GCP secret that provides the spinnsyn datastream credentials."
  type        = string
  default     = "spinnsyn-datastream-credentials"
}

variable "sykepengesoknad_bigquery_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad database credentials."
  type        = string
  default     = "sykepengesoknad-bigquery-credentials"
}

variable "sykepengesoknad_datastream_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad datastream credentials."
  type        = string
  default     = "sykepengesoknad-datastream-credentials"
}

variable "arkivering_oppgave_bigquery_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad-arkivering-oppgave database credentials."
  type        = string
  default     = "arkivering-oppgave-bigquery-credentials"
}

variable "arkivering_oppgave_datastream_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad-arkivering-oppgave datastream credentials."
  type        = string
  default     = "arkivering-oppgave-datastream-credentials"
}

variable "sak_status_metrikk_bigquery_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad-sak-status-metrikk database credentials."
  type        = string
  default     = "sak-status-metrikk-bigquery-credentials"
}

variable "sak_status_metrikk_datastream_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad-sak-status-metrikk datastream credentials."
  type        = string
  default     = "sak-status-metrikk-datastream-credentials"
}

variable "flexjar_datastream_secret" {
  description = "The key of the GCP secret that provides the flexjar datastream credentials."
  type        = string
  default     = "flexjar-datastream-credentials"
}

variable "modia_kontakt_metrikk_datastream_secret" {
  description = "The key of the GCP secret that provides the flex-modia-kontakt-metrikk datastream credentials."
  type        = string
  default     = "flex-modia-kontakt-metrikk-datastream-credentials"
}

variable "sykepengesoknad_cloud_sql_port" {
  description = "The port exposed by the sykepengesoknad database Cloud SQL instance."
  type        = string
  default     = "5432"
}

variable "spinnsyn_cloud_sql_port" {
  description = "The port exposed by the spinnsyn database Cloud SQL instance."
  type        = string
  default     = "5442"
}

variable "arkivering_oppgave_cloud_sql_port" {
  description = "The port exposed by the sykepengesoknad-arkviering-oppgave database Cloud SQL instance."
  type        = string
  default     = "5452"
}

variable "sak_status_metrikk_cloud_sql_port" {
  description = "The port exposed by the sykepengesoknad-sak-status-metrikk database Cloud SQL instance."
  type        = string
  default     = "5462"
}

variable "flexjar_cloud_sql_port" {
  description = "The port exposed by the flexjar-backend database Cloud SQL instance."
  type        = string
  default     = "5472"
}

variable "modia_kontakt_metrikk_cloud_sql_port" {
  description = "The port exposed by the flex-modia-kontakt-metrikk database Cloud SQL instance."
  type        = string
  default     = "5482"
}