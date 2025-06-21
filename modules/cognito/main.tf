resource "aws_cognito_user_pool" "feedback" {
    name = "${var.project_name}-${var.environment}-user-pool"

    auto_verified_attributes = ["email"]
    username_attributes = ["email"]

    password_policy {
      minimum_length = 8
      require_uppercase = true
      require_lowercase = true
      require_numbers = true
      require_symbols = true
    }
}

resource "aws_cognito_user_pool_client" "feedback" {
  name         = "${var.project_name}-${var.environment}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.feedback.id
  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
  supported_identity_providers = ["COGNITO"]
}