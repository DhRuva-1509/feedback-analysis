output "user_pool_id" {
  value = aws_cognito_user_pool.feedback.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.feedback.id
}
