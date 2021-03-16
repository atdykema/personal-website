variable "website_type" {
  description = "use either s3 or ec2 setup"
  default     = "s3"
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 3.31"
}

module "website" {
  source = "./terraform_files/${var.website_type}"
}