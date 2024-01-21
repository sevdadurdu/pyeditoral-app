terraform {
  required_version = ">= 0.13"

  backend "s3" {
    bucket         = "terraform-states-pyeditoral"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
  }
}
