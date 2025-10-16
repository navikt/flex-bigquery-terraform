resource "google_monitoring_notification_channel" "slack" {
  count        = var.type == "slack" ? 1 : 0
  display_name = var.display_name
  type         = var.type
  description  = var.description
  labels       = var.labels
  enabled      = var.enabled
}