output "notification_channel_id" {
  description = "ID til notifikasjon kanal"
  value       = google_monitoring_notification_channel.slack[0].id
}

