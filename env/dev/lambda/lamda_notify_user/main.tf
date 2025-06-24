module "lambda_notify_user" {
  source = "../../../../modules/lambda/lambda_notify_users"
  project_name = var.project_name
  environment =  var.environment
  sns_topic_arn = var.sns_topic_arn
  lambda_zip_path = var.lambda_zip_path
  s3_bucket_arn = var.s3_bucket_arn
}