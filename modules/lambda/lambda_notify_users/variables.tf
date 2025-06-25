variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_zip_path" {
  type = string
}

variable "sns_topic_arn" {
  type = string
  default = "arn:aws:sqs:ca-central-1:796973501829:feedback-system-dev-feedback-results"
}

variable "aws_region" {
  type = string
}

variable "sqs_queue_arn" {
  type = string
}