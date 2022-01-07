#https://www.terraform.io/language/values/outputs
output "vpc_arn" {
  description = "VPC arn."
  value       = aws_vpc.this.arn
}

output "vpc_id" {
  description = "VPC Id."
  value       = aws_vpc.this.id
}
