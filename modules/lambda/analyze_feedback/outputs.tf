output "lambda_function_name" {
  value = aws_lambda_function.analyze_feedback.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.analyze_feedback.arn
}

output "lambda_role_name" {
  value = aws_iam_role.lambda_exec.name
}