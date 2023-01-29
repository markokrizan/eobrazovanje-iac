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

module "dns" {
  source = "./resources/dns"  
}

module "elastic-beanstalk-app" {
  source = "./resources/app-platform"
  certificate_arn = module.dns.certificate_arn
  zone_id = module.dns.zone_id
  depends_on = [
    module.dns
  ]
}

module "database" {
  source = "./resources/database"  
}

module "cdn" {
  source = "./resources/cdn"  
}
