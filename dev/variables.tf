variable "gcp_project" {
  description = "GCP project and region defaults."
  type        = map(string)
  default = {
    region  = "europe-north1",
    zone    = "europe-north1-a",
    project = "flex-dev-2b16"
  }
}

variable "spinnsyn_datastream_secret" {
  description = "The key of the GCP secret that provides credentials to the spinnsyn-db datastram user."
  type        = string
  default     = "spinnsyn-datastream-credentials"
}

variable "spinnsyn_cloud_sql_port" {
  description = "The Cloud SQL Auth Proxy port for spinnsyn-db."
  type        = string
  default     = "5442"
}

