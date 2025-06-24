resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-${var.environment}-analyze-feedback-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "custom_permissions" {
 name = "${var.project_name}-${var.environment}-analyze-feedback-policy"
 role = aws_iam_role.lambda_exec.id

 policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "comprehend:DetectSentiment",
          "comprehend:DetectEntities"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_lambda_function" "analyze_feedback" {
  function_name = "${var.project_name}-${var.environment}-analyze-feedback"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.12"
  handler       = "index.handler"

  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      BUCKET_NAME     = var.s3_bucket_name
      SNS_TOPIC_ARN   = var.sns_topic_arn
    }
  }
}