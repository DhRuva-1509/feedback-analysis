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
}

variable "sqs_queue_arn" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}