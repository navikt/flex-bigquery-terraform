variable "gcp_project" {
  description = "GCP project and region defaults."
  type        = map(string)
  default = {
    region  = "europe-north1",
    project = "flex-dev-2b16"
  }
}

variable "scheduled_query_data_source_id" {
  description = "The documentation states that this value can be changed, but any other value causes a failure."
  type        = string
  default     = "scheduled_query"
}

variable "spinnsyn_bigquery_secret" {
  description = "The key of the GCP secret that provides the spinnsyn database credentials."
  type        = string
}

variable "sykepengesoknad_bigquery_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad database credentials."
  type        = string
}

variable "sykepengesoknad_sak_status_bigquery_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad-sak-status-metrikk database credentials."
  type        = string
}

variable "arkivering_oppgave_bigquery_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad-arkivering-oppgave database credentials."
  type        = string
}

