variable "display_name" {
  description = "Visningsnavn for alarm policy"
  type        = string
}

variable "filter" {
  description = "Logg filter for alarm betingelse"
  type        = string
}

variable "notification_channels" {
  description = "Liste over notification channels"
  type        = list(string)
  default     = []
}

variable "enabled" {
  description = "Om alarm policy skal være aktivert"
  type        = bool
  default     = true
}

variable "combiner" {
  description = "Kombiner for betingelser"
  type        = string
  default     = "OR"
}

variable "notification_rate_limit_period" {
  description = "Periode for notifikasjon rate limit"
  type        = string
  default     = "3600s"
}

variable "auto_close_period" {
  description = "Periode for automatisk lukking av alarmer"
  type        = string
  default     = "604800s"
}

variable "label_extractors" {
  description = "Map av label extractors for å ekstrahere verdier fra logger"
  type        = map(string)
  default     = {}
}

variable "documentation" {
  description = "Dokumentasjon som vises i varsler. Kan bruke log.extracted_label.KEY for å referere til ekstraherte labels"
  type        = string
  default     = ""
}

variable "condition_display_name" {
  description = "Visningsnavn for alarm betingelse"
  type        = string
  default     = "Log match condition"
}
