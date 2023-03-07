variable "gcp_project" {
  description = "GCP project and region defaults."
  type        = map(string)
  default     = {
    region  = "europe-north1",
    zone    = "europe-north1-a",
    project = "flex-prod-af40"
  }
}

variable "scheduled_query_data_source_id" {
  description = "The documentation states that this value can be changed, but any other value causes a failure."
  type        = string
  default     = "scheduled_query"
}

variable "datastream_vpc_ip_range" {
  description = "The IP-range used to provide SQL instances with a private IP address."
  type        = string
  default     = "10.18.0.0"
}

variable "spinnsyn_bigquery_secret" {
  description = "The key of the GCP secret that provides the spinnsyn database credentials."
  type        = string
}

variable "spinnsyn_datastream_secret" {
  description = "The key of the GCP secret that provides the spinnsyn datastream credentials."
  type        = string
}

variable "sykepengesoknad_bigquery_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad database credentials."
  type        = string
}

variable "sykepengesoknad_datastream_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad datastream credentials."
  type        = string
}

variable "arkivering_oppgave_bigquery_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad-arkivering-oppgave database credentials."
  type        = string
}

variable "arkivering_oppgave_datastream_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad-arkivering-oppgave datastream credentials."
  type        = string
}

variable "sak_status_metrikk_bigquery_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad-sak-status-metrikk database credentials."
  type        = string
}

variable "sak_status_metrikk_datastream_secret" {
  description = "The key of the GCP secret that provides the sykepengesoknad-sak-status-metrikk datastream credentials."
  type        = string
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