# Configure the AWS Provider
provider "aws" {
  region              = var.region
  profile             = var.profile_name
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = var.default_tag_list
  }

}
