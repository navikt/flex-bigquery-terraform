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