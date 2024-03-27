terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "canada"
  region = "ca-central-1"
}

provider "aws" {
  alias  = "ohio"
  region = "us-east-2"
}

module "s3_bucket_london" {
  source     = "../../modules/s3"
  providers  = { aws = aws.london }
  buckets = [
    { name = "londonbucket134", block_public = false },
    { name = "londonbucket245545", block_public = false },
    // Add the rest accordingly...
  ]
}

module "s3_bucket_canada" {
  source     = "../../modules/s3"
  providers  = { aws = aws.canada }
  buckets = [
    { name = "canadabest123", block_public = false },
    { name = "secondcanadabest938", block_public = false },
    // Add the rest accordingly...
  ]
}


module "s3_bucket_ohio" {
  source     = "../../modules/s3"
  providers  = { aws = aws.ohio }
  buckets = [
    { name = "ohiobest039394", block_public = false },
    { name = "ohioseconbest23", block_public = false },
    // Add the rest accordingly...
  ]
}

