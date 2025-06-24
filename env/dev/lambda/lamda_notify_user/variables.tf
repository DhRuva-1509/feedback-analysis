variable "project_name" {
  type = string
}
variable "environment" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}
variable "lambda_zip_path" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "aws_profile" {
  type = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for processed feedback files"
  type = string
}