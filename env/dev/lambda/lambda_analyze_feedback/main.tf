module "lambda_analyze_feedback" {
  source = "../../../../modules/lambda/analyze_feedback"
  project_name = var.project_name
  environment = var.environment
  lambda_zip_path = var.lambda_zip_path
  s3_bucket_name = var.s3_bucket_name
  s3_bucket_arn = var.s3_bucket_arn
}