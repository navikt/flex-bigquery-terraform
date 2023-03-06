variable "gcp_project" {
  description = "GCP project and region defaults."
  type        = map(string)
  default = {
    region  = "europe-north1",
    zone    = "europe-north1-a",
    project = "flex-dev-2b16"
  }
}

variable "datastream_vpc_ip_range" {
  description = "The IP-range used to provide SQL instances with a private IP address."
  type        = string
  default     = "10.96.112.0"
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

variable "sykepengesoknad_datastream_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad datastream credentials."
  type        = string
}

variable "spinnsyn_datastream_secret" {
  description = "The key of the GCP secret that provides the spinnsyn datastream credentials."
  type        = string
}

variable "arkivering_oppgave_datastream_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad-arkivering-oppgave datastream credentials."
  type        = string
}
