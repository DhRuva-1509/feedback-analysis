module "lambda_analyze_feedback" {
  source           = "../../../../modules/lambda/analyze_feedback"
  project_name     = var.project_name
  environment      = var.environment
  lambda_zip_path  = var.lambda_zip_path
  s3_bucket_name   = var.s3_bucket_name
  s3_bucket_arn    = var.s3_bucket_arn
  sns_topic_arn    = var.sns_topic_arn
  aws_region       = var.aws_region
}

resource "aws_iam_policy" "lambda_comprehend_policy" {
  name        = "${var.project_name}-${var.environment}-analyze-comprehend-policy"
  description = "Allows Lambda to use Comprehend, S3 Read, CloudWatch, and SNS"

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
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_comprehend_policy" {
  role       = module.lambda_analyze_feedback.lambda_role_name
  policy_arn = aws_iam_policy.lambda_comprehend_policy.arn
}
