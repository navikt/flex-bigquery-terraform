variable "display_name" {
  description = "Visningsnavn for notifikasjon kanal"
  type        = string
}

variable "type" {
  description = "Type notifikasjon kanal (slack, email, etc.)"
  type        = string
}

variable "description" {
  description = "Beskrivelse av notifikasjon kanalen"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels for notifikasjon kanal - for Slack: auth_token og channel_name"
  type        = map(string)
  default     = {}
}

variable "enabled" {
  description = "Om notifikasjon kanal skal være aktivert"
  type        = bool
  default     = true
}
