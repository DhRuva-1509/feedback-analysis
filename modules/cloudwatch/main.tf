resource "aws_cloudwatch_metric_alarm" "lambda_error_rate" {
  alarm_name                = "${var.project_name}-${var.environment}-lambda-error-rate"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  threshold                 = 1
  treat_missing_data        = "notBreaching"

  metric_query {
    id          = "e1"
    expression  = "m1 / m2 * 100"
    label       = "Error Rate %"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      namespace   = "AWS/Lambda"
      metric_name = "Errors"
      period      = 300
      stat        = "Sum"
      dimensions = {
        FunctionName = var.lambda_function_name
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      namespace   = "AWS/Lambda"
      metric_name = "Invocations"
      period      = 300
      stat        = "Sum"
      dimensions = {
        FunctionName = var.lambda_function_name
      }
    }
  }

  alarm_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-throttles"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  dimensions = {
    FunctionName = var.lambda_function_name
  }
  alarm_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-duration"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 3000
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  dimensions = {
    FunctionName = var.lambda_function_name
  }
  alarm_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "sns_failures" {
  alarm_name          = "${var.project_name}-${var.environment}-sns-failures"
  metric_name         = "NumberOfNotificationsFailed"
  namespace           = "AWS/SNS"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  dimensions = {
    TopicName = var.sns_topic_name
  }
  alarm_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_dashboard" "feedback_dashboard" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width = 6,
        height = 6,
        properties = {
          metrics = [["AWS/Lambda", "Duration", "FunctionName", var.lambda_function_name]],
          stat     = "Average",
          period   = 300,
          region   = var.aws_region,
          title    = "Lambda Duration"
        }
      },
      {
        type = "metric",
        x    = 6,
        y    = 0,
        width = 6,
        height = 6,
        properties = {
          metrics = [["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_name]],
          stat     = "Sum",
          period   = 300,
          region   = var.aws_region,
          title    = "Lambda Errors"
        }
      },
      {
        type = "metric",
        x    = 0,
        y    = 6,
        width = 6,
        height = 6,
        properties = {
          metrics = [["AWS/Lambda", "Throttles", "FunctionName", var.lambda_function_name]],
          stat     = "Sum",
          period   = 300,
          region   = var.aws_region,
          title    = "Lambda Throttles"
        }
      },
      {
        type = "metric",
        x    = 6,
        y    = 6,
        width = 6,
        height = 6,
        properties = {
          metrics = [["AWS/SNS", "NumberOfNotificationsFailed", "TopicName", var.sns_topic_name]],
          stat     = "Sum",
          period   = 300,
          region   = var.aws_region,
          title    = "SNS Notification Failures"
        }
      },
      {
        type = "metric",
        x    = 0,
        y    = 12,
        width = 6,
        height = 6,
        properties = {
          metrics = [["AWS/Cognito", "FailedAuthenticationRequests"]],
          stat     = "Sum",
          period   = 300,
          region   = var.aws_region,
          title    = "Auth Failures"
        }
      },
      {
        type = "metric",
        x    = 6,
        y    = 12,
        width = 6,
        height = 6,
        properties = {
          metrics = [["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_name]],
          stat     = "Sum",
          period   = 300,
          region   = var.aws_region,
          title    = "Total Invocations"
        }
      }
    ]
  })
}