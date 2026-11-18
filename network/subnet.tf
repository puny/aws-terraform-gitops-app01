resource "aws_subnet" "public" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value.public_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet-${each.value.az_suffix}"
    Cost = "${var.vpc_name}-public-subnet-${each.value.az_suffix}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = local.subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value.private_cidr

  tags = {
    Name = "${var.vpc_name}-private-subnet-${each.value.az_suffix}"
    Cost = "${var.vpc_name}-private-subnet-${each.value.az_suffix}"
    Tier = "private"
  }
}
