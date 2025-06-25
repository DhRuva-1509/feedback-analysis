module "s3_uploads" {
  source       = "../../../../modules/s3"
  project_name = var.project_name
  environment  = var.environment
  bucket_name  = var.s3_bucket_name
}

module "sqs" {
  source       = "../../../../modules/sqs"
  project_name = var.project_name
  environment  = var.environment
}

module "lambda_analyze_feedback" {
  source           = "../../../../modules/lambda/analyze_feedback"
  project_name     = var.project_name
  environment      = var.environment
  lambda_zip_path  = var.lambda_zip_path
  s3_bucket_name   = var.s3_bucket_name
  s3_bucket_arn    = var.s3_bucket_arn
  sns_topic_arn    = var.sns_topic_arn
  aws_region       = var.aws_region
  sqs_queue_url    = module.sqs.queue_url
}

resource "aws_iam_policy" "lambda_comprehend_policy" {
  name        = "${var.project_name}-${var.environment}-analyze-comprehend-policy"
  description = "Allows Lambda to use Comprehend, S3 Read, CloudWatch, SNS, and SQS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "comprehend:DetectSentiment",
          "comprehend:DetectKeyPhrases"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:HeadObject"
        ],
        Resource = "${var.s3_bucket_arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = var.sns_topic_arn
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage"
        ],
        Resource = module.sqs.queue_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_comprehend_policy" {
  role       = module.lambda_analyze_feedback.lambda_role_name
  policy_arn = aws_iam_policy.lambda_comprehend_policy.arn
}

resource "aws_lambda_permission" "allow_s3_invoke_analyze_feedback" {
  statement_id  = "AllowS3InvokeAnalyzeFeedback"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_analyze_feedback.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3_uploads.bucket_arn
}

resource "aws_s3_bucket_notification" "analyze_feedback_trigger" {
  bucket = module.s3_uploads.bucket_name

  lambda_function {
    lambda_function_arn = module.lambda_analyze_feedback.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "incoming/"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke_analyze_feedback]
}
