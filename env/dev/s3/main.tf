module "s3_uploads" {
  source = "../../../modules/s3"
  project_name = var.project_name
  environment = var.environment
  bucket_name = var.bucket_name
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3_uploads.bucket_arn
}

resource "aws_s3_bucket_notification" "trigger_analyze" {
  bucket = module.s3_uploads.bucket_name

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "incoming/"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}