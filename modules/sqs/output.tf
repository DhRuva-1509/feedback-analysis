output "queue_url" {
  description = "The URL of thhe SQS queue"
  value = aws_sqs_queue.feedback_results.id
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value = aws_sqs_queue.feedback_results.arn
}