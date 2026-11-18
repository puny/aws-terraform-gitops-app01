variable "region" {
  description = "AWS region in which to create the network."
  type        = string
  default     = "ap-northeast-2"
}

variable "vpc_name" {
  description = "Name used for the VPC and related network resources."
  type        = string
  default     = "dev-vpc"
}

variable "existing_vpc_id" {
  description = "Optional VPC ID used to look up an existing VPC and its tagged subnets."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment tag applied to all resources."
  type        = string
  default     = "development"
}

variable "cost_tag" {
  description = "Value for the Cost tag used for cost allocation."
  type        = string
  default     = "development"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_count" {
  description = "Number of availability zones in which to create subnets."
  type        = number
  default     = 2

  validation {
    condition     = var.availability_zone_count >= 2 && var.availability_zone_count <= 3
    error_message = "availability_zone_count must be between 2 and 3."
  }
}

variable "public_subnet_cidrs" {
  description = "IPv4 CIDR blocks for public subnets, ordered to match the selected availability zones."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == var.availability_zone_count
    error_message = "Provide exactly one public_subnet_cidrs entry per availability zone."
  }
}

variable "private_subnet_cidrs" {
  description = "IPv4 CIDR blocks for private subnets, ordered to match the selected availability zones."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == var.availability_zone_count
    error_message = "Provide exactly one private_subnet_cidrs entry per availability zone."
  }
}
