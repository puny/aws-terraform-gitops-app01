data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = slice(
    sort(data.aws_availability_zones.available.names),
    0,
    var.availability_zone_count
  )

  subnets = {
    for index, zone in local.availability_zones : zone => {
      index        = index
      az_suffix    = substr(zone, length(zone) - 2, 2)
      public_cidr  = var.public_subnet_cidrs[index]
      private_cidr = var.private_subnet_cidrs[index]
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

