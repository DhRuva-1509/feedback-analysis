module "s3_uploads" {
  source = "../../../modules/s3"
  project_name = var.project_name
  environment = var.environment
  bucket_name = var.bucket_name
}