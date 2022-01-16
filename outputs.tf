#https://www.terraform.io/language/values/outputs
output "vpc_arn" {
  description = "VPC arn."
  value       = aws_vpc.this.arn
}

output "vpc_id" {
  description = "VPC Id."
  value       = aws_vpc.this.id
}

output "vpc_private_subnets_id" {
  description = "VPC private subnets"
  value       = aws_subnet.private.*.id
}

output "vpc_private_subnets_cidr" {
  description = "VPC private subnets CIDR"
  value       = local.private_subnets_cidr
}
output "vpc_public_subnets_id" {
  description = "VPC public subnets"
  value       = aws_subnet.public.*.id
}

output "vpc_prublic_subnets_cidr" {
  description = "VPC public subnets CIDR"
  value       = local.public_subnets_cidr
}
