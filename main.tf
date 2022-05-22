terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.15.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}
module "part1" {
  source = "./part1"
}
module "part2" {
  source = "./part2"
  ECR_IMAGE_URI = module.part1.ecr_image_uri
  WEBSITE_BUCKET_NAME = module.part1.website_bucket_name
  LAMBDA_FUNCTION_NAME = module.part1.lambda_function_name
  CODEPIPELINE_NAME = module.part1.codepipeline_name
  ACCOUNT_ID = module.part1.account_id
  REGION = module.part1.region
}