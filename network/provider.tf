provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Cost        = var.cost_tag
    }
  }
}
