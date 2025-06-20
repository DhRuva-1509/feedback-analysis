provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile  # optional, only if using named profile
}