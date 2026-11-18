region               = "ap-northeast-2"
vpc_name             = "aws-terraform-newapp01"
environment          = "development"
cost_tag             = "aws-terraform-newapp01"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
