variable "cloudtrail_logs" {
  type = string
}

data "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name = var.cloudtrail_logs
}

resource "aws_sns_topic" "honeypot-notifications" {
  name            = "honeypotAlarmsTopic"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

resource "aws_cloudwatch_log_metric_filter" "honeyuser-metric" {
  name = "HoneyUser_Activity"
  pattern = "{ $.userIdentity.accessKeyId = ${aws_iam_access_key.honeyuser_key.id} }"
  log_group_name = data.aws_cloudwatch_log_group.cloudtrail_logs.name

  metric_transformation {
    name = "HoneyUser_Activity"
    namespace = "HoneyTokens-tf"
    value = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "honeyuser-activity" {
  alarm_name = "honeyUserActivity"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "2"
  metric_name = aws_cloudwatch_log_metric_filter.honeyuser-metric.name
  namespace = "HoneyTokens-tf"
  period = "60"
  statistic = "Sum"
  threshold = "0"
  alarm_description = "Malicious activity from honey user"
  alarm_actions = [aws_sns_topic.honeypot-notifications.arn]
  treat_missing_data = "notBreaching"
  datapoints_to_alarm = 1
}