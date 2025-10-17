module "flex_slack_notification" {
  source = "../modules/google_monitoring_notification_channel"

  display_name = "Flex Slack Alerts"
  type         = "slack"
  labels = {
    "channel_name" = "#flex-dev"
    "auth_token"   = local.slack_app_access_token
  }
  enabled = true
}