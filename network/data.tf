data "aws_vpc" "existing" {
  count = var.existing_vpc_id == "" ? 0 : 1

  id = var.existing_vpc_id
}

data "aws_subnets" "existing_public" {
  count = var.existing_vpc_id == "" ? 0 : 1

  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }

  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}

data "aws_subnets" "existing_private" {
  count = var.existing_vpc_id == "" ? 0 : 1

  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }

  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}
