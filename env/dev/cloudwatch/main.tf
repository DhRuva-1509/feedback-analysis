module "cloudwatch" {
  source = "../../../modules/cloudwatch"

  project_name         = var.project_name
  environment          = var.environment
  sns_topic_arn        = var.sns_topic_arn
  sns_topic_name       = var.sns_topic_name
  lambda_function_name = var.lambda_function_name
  aws_region           = var.aws_region
  aws_profile          = var.aws_profile
}