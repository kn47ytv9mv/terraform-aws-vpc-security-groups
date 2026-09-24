mock_provider "aws" {}

run "ingress_rules_needs_one_source" {
  command = plan

  variables {
    vpc_id = "vpc-0123456789abcdef0"
    ingress_rules = [{
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv4   = "0.0.0.0/0"
      cidr_ipv6   = "::/0"
    }]
  }

  expect_failures = [var.ingress_rules]
}

run "ingress_rules_needs_a_source" {
  command = plan

  variables {
    vpc_id = "vpc-0123456789abcdef0"
    ingress_rules = [{
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
    }]
  }

  expect_failures = [var.ingress_rules]
}

run "egress_rules_needs_one_destination" {
  command = plan

  variables {
    vpc_id = "vpc-0123456789abcdef0"
    egress_rules = [{
      ip_protocol    = "-1"
      from_port      = -1
      to_port        = -1
      cidr_ipv4      = "0.0.0.0/0"
      prefix_list_id = "pl-0123456789abcdef0"
    }]
  }

  expect_failures = [var.egress_rules]
}

run "egress_rules_needs_a_destination" {
  command = plan

  variables {
    vpc_id = "vpc-0123456789abcdef0"
    egress_rules = [{
      ip_protocol = "-1"
      from_port   = -1
      to_port     = -1
    }]
  }

  expect_failures = [var.egress_rules]
}

run "default_config_creates_no_rules" {
  command = plan

  variables {
    vpc_id = "vpc-0123456789abcdef0"
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.resource) == 0
    error_message = "No ingress_rules were given, so no ingress rule resources should be created."
  }

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.resource) == 0
    error_message = "No egress_rules were given, so no egress rule resources should be created."
  }
}

run "explicit_name_used_instead_of_random_uuid" {
  command = plan

  variables {
    vpc_id = "vpc-0123456789abcdef0"
    name   = "explicit-name"
  }

  assert {
    condition     = aws_security_group.resource.name == "explicit-name"
    error_message = "An explicit name should be used as-is instead of the random UUID fallback."
  }
}

run "multiple_rules_each_create_a_resource" {
  command = plan

  variables {
    vpc_id = "vpc-0123456789abcdef0"
    ingress_rules = [
      { ip_protocol = "tcp", from_port = 443, to_port = 443, cidr_ipv4 = "0.0.0.0/0" },
      { ip_protocol = "tcp", from_port = 22, to_port = 22, cidr_ipv4 = "10.0.0.0/8" },
    ]
    egress_rules = [
      { ip_protocol = "-1", from_port = -1, to_port = -1, cidr_ipv4 = "0.0.0.0/0" },
    ]
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.resource) == 2
    error_message = "Two ingress_rules entries should create two ingress rule resources."
  }

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.resource) == 1
    error_message = "One egress_rules entry should create one egress rule resource."
  }
}

run "readme_cidr_ingress" {
  command = plan

  variables {
    vpc_id = "vpc-0123456789abcdef0"
    ingress_rules = [{
      description = "HTTPS from anywhere"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv4   = "0.0.0.0/0"
    }]
  }
}

run "readme_referenced_security_group_ingress" {
  command = plan

  variables {
    vpc_id = "vpc-0123456789abcdef0"
    ingress_rules = [{
      description                  = "App traffic from the load balancer"
      ip_protocol                  = "tcp"
      from_port                    = 8080
      to_port                      = 8080
      referenced_security_group_id = "sg-0123456789abcdef0"
    }]
  }
}
