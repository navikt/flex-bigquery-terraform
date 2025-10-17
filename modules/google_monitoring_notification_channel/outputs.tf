output "notification_channel_id" {
  description = "ID til notifikasjon kanal"
  value       = google_monitoring_notification_channel.notification_channel.id
}

