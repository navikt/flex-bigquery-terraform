module "auditlog_flex_alert" {
  source = "../modules/google_monitoring_alert_policy"

  display_name                   = "Auditlog GCP"
  filter                         = "protoPayload.request.user=~\".*@nav.no\"\nlogName=\"projects/flex-prod-af40/logs/cloudaudit.googleapis.com%2Fdata_access\""
  notification_channels          = [module.flex_slack_notification.notification_channel_id]
  enabled                        = true
  combiner                       = "OR"
  notification_rate_limit_period = "300s"
  auto_close_period              = "604800s"
  condition_display_name         = "Manuell aktivitet"

  label_extractors = {
    "command"  = "EXTRACT(protoPayload.request.command)"
    "user"     = "EXTRACT(protoPayload.request.user)"
    "database" = "EXTRACT(protoPayload.resourceName)"
  }

  documentation = <<-EOT
  *🚨 Manuell aktivitet oppdaget*

  Noen har utført en manuell operasjon i GCP som krever oppmerksomhet:

  *Bruker:* $${log.extracted_label.user}
  *Database:* $${log.extracted_label.database}
  *SQL Kommando:* $${log.extracted_label.command}

  ⚠️ Vennligst undersøk om denne handlingen er autorisert.
  EOT
}
