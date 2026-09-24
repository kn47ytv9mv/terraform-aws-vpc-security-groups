variable "name" {
  default     = null
  description = "The name of the security group. If null, a unique name is generated."
}

variable "vpc_id" {
  default     = null
  description = "The ID of the VPC in which to create the security group."
}

variable "description" {
  default     = null
  description = "Description of the security group. If null, AWS defaults it to 'Managed by Terraform'."
}

variable "ingress_rules" {
  default     = []
  description = "Ingress rules for the security group. Each entry needs ip_protocol and exactly one source (cidr_ipv4, cidr_ipv6, prefix_list_id, or referenced_security_group_id). For ip_protocol = '-1' (all protocols), set from_port and to_port to -1 rather than leaving them null."
  type = list(object({
    description                  = optional(string)
    ip_protocol                  = string
    from_port                    = optional(number)
    to_port                      = optional(number)
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
  }))

  validation {
    condition = alltrue([
      for r in var.ingress_rules : length([
        for v in [r.cidr_ipv4, r.cidr_ipv6, r.prefix_list_id, r.referenced_security_group_id] : v if v != null
      ]) == 1
    ])
    error_message = "Each ingress_rules entry needs exactly one of cidr_ipv4, cidr_ipv6, prefix_list_id, or referenced_security_group_id."
  }
}

variable "egress_rules" {
  default     = []
  description = "Egress rules for the security group. Each entry needs ip_protocol and exactly one destination (cidr_ipv4, cidr_ipv6, prefix_list_id, or referenced_security_group_id). For ip_protocol = '-1' (all protocols), set from_port and to_port to -1 rather than leaving them null. AWS automatically creates a default allow-all-IPv4-egress rule for every new security group; this module does not manage or remove it, so outbound traffic stays unrestricted unless that default is revoked separately."
  type = list(object({
    description                  = optional(string)
    ip_protocol                  = string
    from_port                    = optional(number)
    to_port                      = optional(number)
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
  }))

  validation {
    condition = alltrue([
      for r in var.egress_rules : length([
        for v in [r.cidr_ipv4, r.cidr_ipv6, r.prefix_list_id, r.referenced_security_group_id] : v if v != null
      ]) == 1
    ])
    error_message = "Each egress_rules entry needs exactly one of cidr_ipv4, cidr_ipv6, prefix_list_id, or referenced_security_group_id."
  }
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the security group."
}
