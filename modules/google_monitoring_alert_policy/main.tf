resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = var.display_name
  combiner     = var.combiner
  enabled      = var.enabled

  conditions {
    display_name = var.condition_display_name
    condition_matched_log {
      filter           = var.filter
      label_extractors = var.label_extractors
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = var.notification_rate_limit_period
    }
    auto_close = var.auto_close_period
    notification_prompts = ["OPENED"]
  }

  dynamic "documentation" {
    for_each = var.documentation != "" ? [1] : []
    content {
      content   = var.documentation
      mime_type = "text/markdown"
    }
  }

  notification_channels = var.notification_channels
}