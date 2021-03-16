variable "website_type" {
    description = "choose between ec2 or s3 website hosting, chooses s3 by default"
    default = "./terraform_files/s3"
} 

provider "aws" {
  region = "us-east-1"
  version = "~> 3.31"
}

module "website" {
  source = var.website_type
}