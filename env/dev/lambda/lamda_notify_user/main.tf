module "lambda_notify_user_from_sqs" {
  source           = "../../../../modules/lambda/lambda_notify_users"
  project_name     = var.project_name
  environment      = var.environment
  lambda_zip_path  = var.lambda_zip_path
  sns_topic_arn    = var.sns_topic_arn
  sqs_queue_arn    = var.sqs_queue_arn
  aws_region       = var.aws_region
}

output "lambda_function_name" {
  value = module.lambda_notify_user_from_sqs.lambda_function_name
}

output "lambda_function_arn" {
  value = module.lambda_notify_user_from_sqs.lambda_function_arn
}
