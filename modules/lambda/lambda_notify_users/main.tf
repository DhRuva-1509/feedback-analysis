resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-${var.environment}-notify-user-lambda-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
    role = aws_iam_role.lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  
}

resource "aws_iam_role_policy" "sns_publish" {
  name = "${var.project_name}-${var.environment}-sns-publish-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_lambda_function" "notify_user" {
  function_name = "${var.project_name}-${var.environment}-notify-user"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.12"
  handler       = "index.handler"

  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
}

resource "aws_iam_role_policy" "notify_user_permissions" {
  name = "${var.project_name}-${var.environment}-notify-user-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["sns:Publish"],
        Resource = var.sns_topic_arn
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject"],
        Resource = "${var.s3_bucket_arn}/processed/*"
      }
    ]
  })
}