resource "google_monitoring_notification_channel" "notification_channel" {
  display_name = var.display_name
  type         = var.type
  description  = var.description
  labels       = var.labels
  enabled      = var.enabled
}