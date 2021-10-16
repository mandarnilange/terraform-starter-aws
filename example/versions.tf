terraform {
  # experiments = [module_variable_optional_attrs]

  # TODO Uncomment below for using S3 as storage for the terraform state and update right values 
  # backend "s3" {
  #   bucket = "bucket-name"
  #   key    = "development/tfstate"

  #   region  = "ap-south-1"
  #   profile = "tf-user"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
