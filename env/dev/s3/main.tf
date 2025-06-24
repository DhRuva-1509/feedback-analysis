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

resource "aws_s3_bucket_notification" "notify_user_trigger" {
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = module.lambda_notify_user.lambda_function_arn
    events = [ "s3:ObjectCreated:*" ]
    filter_prefix = "processed/"
    filter_suffix = "_result.json"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke_notify_user
  ]
}

resource "aws_lambda_permission" "allow_s3_invoke_notify_user" {
  statement_id = "AllowS3InvokeNotify_User"
  action = "lambda:InvokeFunction"
  function_name = module.lambda_notify_user.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}