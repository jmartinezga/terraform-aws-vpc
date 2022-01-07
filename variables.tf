#https://www.terraform.io/language/values/variables
variable "vpc_name" {
  description = "(Required) VPC name."
  type        = string

  validation {
    condition     = length(var.vpc_name) > 0
    error_message = "VPC name is required."
  }
}

variable "vpc_cidr_block" {
  description = "(Required) The IPv4 CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(regex("\\d{1,3}[.]{1}\\d{1,3}[.]{1}\\d{1,3}[.]{1}\\d{1,3}[/]{1}(8|16)", var.vpc_cidr_block))
    error_message = "VPC name is required."
  }
}

###############################################################################
# OPTIONAL
###############################################################################
variable "vpc_instance_tenacy" {
  description = "(Optional) A tenancy option for instances launched into the VPC. Defaults 'default'."
  type        = string
  default     = "default"
}

variable "vpc_enable_dns_support" {
  description = "(Optional) A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type        = bool
  default     = true
}
variable "vpc_enable_dns_hostnames" {
  description = "(Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) Tags to assign to the resource."
  type        = any
  default     = {}
}
