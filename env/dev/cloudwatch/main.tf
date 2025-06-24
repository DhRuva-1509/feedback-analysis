module "cloudwatch" {
  source = "../../../modules/cloudwatch"

  project_name         = var.project_name
  environment          = var.environment
  sns_topic_arn        = var.sns_topic_arn
  sns_topic_name       = var.sns_topic_name
  lambda_function_name = var.lambda_function_name
  aws_region           = var.aws_region
  aws_profile          = var.aws_profile
}
resource "aws_cloudwatch_metric_alarm" "notify_user_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-notify-user-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when notify_user Lambda fails"
  dimensions = {
    FunctionName = module.lambda_notify_user.lambda_function_name
  }
  alarm_actions = [var.sns_topic_arn]
}