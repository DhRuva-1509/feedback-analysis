module "lambda_notify_user" {
  source = "../../../../modules/lambda/lambda_notify_users"
  project_name = var.project_name
  environment =  var.environment
  sns_topic_arn = var.sns_topic_arn
  lambda_zip_path = var.lambda_zip_path
  s3_bucket_arn = var.s3_bucket_arn
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3InvokeNotifyUser"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_notify_user.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "notify_user_trigger" {
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = module.lambda_notify_user.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "processed/"
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}