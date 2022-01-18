#https://www.terraform.io/language/values/outputs
output "arn" {
  description = "VPC arn."
  value       = aws_vpc.this.arn
}

output "id" {
  description = "VPC Id."
  value       = aws_vpc.this.id
}

output "cidr" {
  description = "VPC CIDR"
  value       = var.vpc_cidr_block
}
output "private_subnets_id" {
  description = "VPC private subnets"
  value       = aws_subnet.private.*.id
}

output "private_subnets_cidr" {
  description = "VPC private subnets CIDR"
  value       = local.private_subnets_cidr
}
output "public_subnets_id" {
  description = "VPC public subnets"
  value       = aws_subnet.public.*.id
}

output "public_subnets_cidr" {
  description = "VPC public subnets CIDR"
  value       = local.public_subnets_cidr
}
