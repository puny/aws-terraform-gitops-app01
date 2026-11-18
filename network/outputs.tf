output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs, suitable for development EC2 instances."
  value       = [for zone in local.availability_zones : aws_subnet.public[zone].id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs. No NAT Gateway or internet route is configured."
  value       = [for zone in local.availability_zones : aws_subnet.private[zone].id]
}

output "internet_gateway_id" {
  description = "ID of the VPC Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "existing_vpc_id" {
  description = "ID of the optionally looked-up existing VPC, or null when not configured."
  value       = var.existing_vpc_id == "" ? null : data.aws_vpc.existing[0].id
}

output "existing_public_subnet_ids" {
  description = "Public subnet IDs in the looked-up VPC tagged Tier=public."
  value       = var.existing_vpc_id == "" ? [] : data.aws_subnets.existing_public[0].ids
}

output "existing_private_subnet_ids" {
  description = "Private subnet IDs in the looked-up VPC tagged Tier=private."
  value       = var.existing_vpc_id == "" ? [] : data.aws_subnets.existing_private[0].ids
}
