variable "project" {
  description = "The project identifier."
  type        = string
}

variable "region" {
  description = "The projects default region."
  type        = string
}

variable "spinnsyn_db_secret" {
  description = "The key of the GCP secrete used to access the spinnsyn database."
  type        = string
}

variable "scheduled_query" {
  description = "The documentation states that this value can be changed, but any other value causes a failure."
  type        = string
  default     = "scheduled_query"
}
