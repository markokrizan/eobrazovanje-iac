terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    bucket  = "ftn-edu-app-iac"
    key     = "terraform"
    region  = "eu-central-1"
    encrypt = true
  }
}

provider "aws" {
  region  = "eu-central-1"
}

module "elastic-beanstalk-app" {
  source = "./resources/app-platform"  
}
