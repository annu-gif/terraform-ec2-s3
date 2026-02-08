provider "aws" {
  region = var.aws_region
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

module "ec2" {
  source      = "./modules/ec2"
  bucket_name = module.s3.bucket_name
  bucket_arn  = module.s3.bucket_arn
}

