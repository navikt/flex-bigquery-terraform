variable "gcp_project" {
  description = "GCP project and region defaults."
  type        = map(string)
  default = {
    region  = "europe-north1",
    project = "flex-prod-af40"
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
