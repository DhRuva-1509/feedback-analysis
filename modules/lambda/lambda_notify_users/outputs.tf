output "lambda_function_name" {
  value = aws_lambda_function.notify_user_from_sqs.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.notify_user_from_sqs.arn
}