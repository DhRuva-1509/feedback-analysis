output "topic_arn" {
  description = "SNS topic ARN"
  value = aws_sns_topic.feedback.arn
}

output "topic_name" {
  description = "SNS topic name"
  value = aws_sns_topic.feedback.name
}