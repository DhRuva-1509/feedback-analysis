module "sns" {
  source = "../../../modules/sns"
  project_name = var.project_name
  environment = var.environment
  notification_email = var.notification_email
}