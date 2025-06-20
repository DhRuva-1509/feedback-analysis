variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "notification_email" {
  type = string
}
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}