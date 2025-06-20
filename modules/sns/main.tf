resource "aws_sns_topic" "feedback" {
    name = "${var.project_name}-${var.environment}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count = var.notification_email != "" ? 1 :0
  topic_arn = aws_sns_topic.feedback.arn
  protocol = "email"
  endpoint = var.notification_email
}