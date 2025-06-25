variable "project_name" {}
variable "environment" {}
variable "lambda_zip_path" {}
variable "s3_bucket_name" {}
variable "s3_bucket_arn" {}
variable "sns_topic_arn" {}
variable "aws_region" {}
variable "sqs_queue_url" {
  type = string
}