variable "gcp_project" {
  description = "GCP project and region defaults."
  type        = map(string)
  default = {
    region  = "europe-north1",
    zone    = "europe-north1-a",
    project = "flex-dev-2b16"
  }
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

