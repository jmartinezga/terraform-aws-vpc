#https://registry.terraform.io/providers/hashicorp/aws/latest/docs
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  vpc_name                = "${var.environment}-${var.vpc_name}"
  availability_zones      = length(data.aws_availability_zones.available) < 3 ? length(data.aws_availability_zones.available) : 3
  availability_zones_name = data.aws_availability_zones.available.names
  private_subnets_cidr    = [for k in range(1, local.availability_zones + 1) : cidrsubnet(var.vpc_cidr_block, 8, k)]
  public_subnets_cidr     = [for k in range(local.availability_zones + 1, (local.availability_zones * 2) + 1) : cidrsubnet(var.vpc_cidr_block, 8, k)]
  module_version          = trimspace(chomp(file("./version")))
  last_update             = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  tags = merge(var.tags, {
    environment    = "${var.environment}",
    application    = "${var.application}",
    module_name    = "terraform-aws-vpc",
    module_version = "${local.module_version}",
    last_update    = "${local.last_update}"
  })
}

###############################################################################
# VPC
###############################################################################
#https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "this" {
  #ts:skip=AC_AWS_0369 Skip rule
  cidr_block = var.vpc_cidr_block

  instance_tenancy     = var.vpc_instance_tenacy
  enable_dns_support   = var.vpc_enable_dns_support
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  tags                 = merge({ "Name" = local.vpc_name }, local.tags)
}

###############################################################################
# INTERNET GATEWAY
###############################################################################
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ "Name" = local.vpc_name }, local.tags)
}

###############################################################################
# NAT GATEWAY + EIP
###############################################################################
# https://www.terraform.io/docs/providers/aws/r/eip.html
resource "aws_eip" "nat_gateway" {
  count = var.environment == "prd" ? length(local.private_subnets_cidr) : 1

  vpc  = true
  tags = merge({ "Name" = format("%s-nat-%d", local.vpc_name, count.index) }, local.tags)

  # Note: EIP may require IGW to exist prior to association. Use depends_on to set an explicit dependency on the IGW.
  depends_on = [aws_internet_gateway.this]
}

# https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
resource "aws_nat_gateway" "this" {
  count = var.environment == "prd" ? length(local.private_subnets_cidr) : 1

  allocation_id = aws_eip.nat_gateway.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]
  tags          = merge({ "Name" = format("%s-%d", local.vpc_name, count.index) }, local.tags)

  depends_on = [aws_internet_gateway.this]
}

###############################################################################
# PRIVATE SUBNETS + ROUTE TABLE + NETWORK ACLs
###############################################################################
# https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "private" {
  count = length(local.private_subnets_cidr)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.private_subnets_cidr[count.index]
  availability_zone       = local.availability_zones_name[count.index]
  map_public_ip_on_launch = false
  tags                    = merge({ "Name" = format("%s-private-%d", local.vpc_name, count.index) }, local.tags)
}

# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "private" {
  count = length(local.private_subnets_cidr)

  vpc_id = aws_vpc.this.id
  tags   = merge({ "Name" = format("%s-private-%d", local.vpc_name, count.index) }, local.tags)
}

# https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "private" {
  count = length(local.private_subnets_cidr)

  route_table_id         = aws_route_table.private.*.id[count.index]
  nat_gateway_id         = var.environment == "prd" ? aws_nat_gateway.this.*.id[count.index] : aws_nat_gateway.this.*.id[0]
  destination_cidr_block = "0.0.0.0/0"
}

# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "private" {
  count = length(local.private_subnets_cidr)

  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}

# https://www.terraform.io/docs/providers/aws/r/network_acl.html
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private.*.id
  tags       = merge({ "Name" = format("%s-private", local.vpc_name) }, local.tags)
}

# https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
#tfsec:ignore:AWS050
resource "aws_network_acl_rule" "private_ingress" {
  network_acl_id = aws_network_acl.private.id
  egress         = false
  from_port      = 0
  to_port        = 0
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

#tfsec:ignore:AWS050
resource "aws_network_acl_rule" "private_egress" {
  network_acl_id = aws_network_acl.private.id
  egress         = true
  from_port      = 0
  to_port        = 0
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

###############################################################################
# PUBLIC SUBNETS + ROUTE TABLE + NETWORK ACLs
###############################################################################
# https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "public" {
  count = length(local.public_subnets_cidr)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnets_cidr[count.index]
  availability_zone       = local.availability_zones_name[count.index]
  map_public_ip_on_launch = true
  tags                    = merge({ "Name" = format("%s-public-%d", local.vpc_name, count.index) }, local.tags)
}

# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ "Name" = format("%s-public", local.vpc_name) }, local.tags)
}

# https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "public" {
  count = length(local.public_subnets_cidr)

  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

# https://www.terraform.io/docs/providers/aws/r/network_acl.html
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.public.*.id
  tags       = merge({ "Name" = format("%s-public", local.vpc_name) }, local.tags)
}

# https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
#tfsec:ignore:AWS050
resource "aws_network_acl_rule" "public_ingress" {
  network_acl_id = aws_network_acl.public.id
  egress         = false
  from_port      = 0
  to_port        = 0
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

#tfsec:ignore:AWS050
resource "aws_network_acl_rule" "public_egress" {
  network_acl_id = aws_network_acl.public.id
  egress         = true
  from_port      = 0
  to_port        = 0
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}
