resource "random_uuid" "resource" {}

resource "aws_security_group" "resource" {
  vpc_id      = var.vpc_id
  name        = coalesce(var.name, random_uuid.resource.id)
  description = var.description

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "resource" {
  for_each = { for index, rule in var.ingress_rules : index => rule }

  security_group_id = aws_security_group.resource.id

  description                  = each.value.description
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "resource" {
  for_each = { for index, rule in var.egress_rules : index => rule }

  security_group_id = aws_security_group.resource.id

  description                  = each.value.description
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
}

output "id" {
  description = "The ID of the security group."
  value       = aws_security_group.resource.id
}

output "name" {
  description = "The name of the security group."
  value       = aws_security_group.resource.name
}

output "arn" {
  description = "The ARN of the security group."
  value       = aws_security_group.resource.arn
}
