variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "sns_topic_name" {
  type = string
}

variable "lambda_function_name" {
  type = string
}
variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type    = string
  default = "default"
}