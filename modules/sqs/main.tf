resource "aws_sqs_queue" "feedback_results" {
  name = "${var.project_name}-${var.environment}-feedback-results"

   tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}