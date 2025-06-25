output "queue_url" {
  description = "The URL of the SQS queue"
  value       = module.sqs.queue_url
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.sqs.queue_arn
}