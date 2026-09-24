# terraform-aws-vpc-security-groups

Terraform module for a VPC security group with explicit ingress/egress
rules, using the modern `aws_vpc_security_group_ingress_rule` /
`aws_vpc_security_group_egress_rule` resources rather than the deprecated
inline `ingress`/`egress` blocks.

## Cost

Security groups and their rules carry no charge. This module has no
cost impact of its own.

## Usage

```hcl
module "security_group" {
  source = "kn47ytv9mv/vpc-security-groups/aws"

  vpc_id = aws_vpc.example.id

  ingress_rules = [
    {
      description = "HTTPS from anywhere"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}
```

Or directly from this repository:

```hcl
module "security_group" {
  source = "github.com/kn47ytv9mv/terraform-aws-vpc-security-groups"

  vpc_id = aws_vpc.example.id

  ingress_rules = [
    {
      description                  = "App traffic from the load balancer"
      ip_protocol                  = "tcp"
      from_port                    = 8080
      to_port                      = 8080
      referenced_security_group_id = module.load_balancer_security_group.id
    }
  ]
}
```

**Note on egress:** AWS automatically creates a default allow-all-IPv4
egress rule for every new security group. This module only manages
rules declared in `egress_rules` — it does not revoke that default, so
outbound traffic stays unrestricted unless revoked separately, outside
this module (doing so from within would tie the module's behavior to
account/region-specific default rule IDs it does not own).

**Note on cross-VPC references:** `referenced_security_group_id` only
works reliably within a single VPC, or in a same-account, same-region VPC
peering connection with `allow_remote_vpc_dns_resolution` and the
appropriate peering options configured. It does not work across a
Transit Gateway by default — that requires enabling security group
referencing on both sides: `security_group_referencing_support`
on [`terraform-aws-transit-gateway`](https://github.com/kn47ytv9mv/terraform-aws-transit-gateway)
itself, and the matching setting on the attaching VPC's own
[`terraform-aws-transit-gateway-vpc-attachment`](https://github.com/kn47ytv9mv/terraform-aws-transit-gateway-vpc-attachment).
Both default to disabled. Outside of these cases, use `cidr_ipv4`/
`cidr_ipv6` instead.

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.3 |
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| name | The name of the security group. If null, a unique name is generated. | `null` | no |
| vpc_id | The ID of the VPC in which to create the security group. | `null` | no |
| description | Description of the security group. If null, AWS defaults it to `'Managed by Terraform'`. | `null` | no |
| ingress_rules | Ingress rules for the security group. Each entry needs `ip_protocol` and exactly one source (`cidr_ipv4`, `cidr_ipv6`, `prefix_list_id`, or `referenced_security_group_id`). For `ip_protocol = '-1'` (all protocols), set `from_port`/`to_port` to `-1` rather than leaving them null. | `[]` | no |
| egress_rules | Egress rules for the security group. Each entry needs `ip_protocol` and exactly one destination (`cidr_ipv4`, `cidr_ipv6`, `prefix_list_id`, or `referenced_security_group_id`). For `ip_protocol = '-1'` (all protocols), set `from_port`/`to_port` to `-1` rather than leaving them null. AWS automatically creates a default allow-all-IPv4-egress rule for every new security group; this module does not manage or remove it, so outbound traffic stays unrestricted unless that default is revoked separately. | `[]` | no |
| tags | A map of tags to assign to the security group. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the security group. |
| arn | The ARN of the security group. |
| name | The name of the security group. |

## License

MIT — see [LICENSE.md](LICENSE.md).
