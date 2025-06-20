variable "project_name" {
  description = "A tutorial of my serverless course"
  type = string
}

variable "environment" {
  description = "Environment name(dev, prod)"
  type = string
}

variable "notification_email" {
  description = "Optional email address to subscribe to the topic"
  type = string
  default = ""
}