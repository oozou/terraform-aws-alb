/* -------------------------------------------------------------------------- */
/*                                  Generics                                  */
/* -------------------------------------------------------------------------- */
locals {
  alb_name_temp = "${var.prefix}-${var.environment}-${var.name}"
  alb_name      = substr("${local.alb_name_temp}", 0, min(32, length(local.alb_name_temp)))

  alb_aws_security_group_id = var.is_create_alb_security_group ? aws_security_group.alb[0].id : var.alb_aws_security_group_id

  http_ingress_cidr_blocks_v4  = [for cidr in var.http_ingress_cidr_blocks : cidr if can(cidrnetmask(cidr))]
  http_ingress_cidr_blocks_v6  = var.ip_address_type == "dualstack" ? [for cidr in var.http_ingress_cidr_blocks : cidr if !can(cidrnetmask(cidr)) && can(cidrhost(cidr, 0))] : []
  https_ingress_cidr_blocks_v4 = [for cidr in var.https_ingress_cidr_blocks : cidr if can(cidrnetmask(cidr))]
  https_ingress_cidr_blocks_v6 = var.ip_address_type == "dualstack" ? [for cidr in var.https_ingress_cidr_blocks : cidr if !can(cidrnetmask(cidr)) && can(cidrhost(cidr, 0))] : []

  tags = merge(
    {
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}
/* ----------------------------- Raise Condition ---------------------------- */
locals {
  raise_is_alb_security_group_empty  = var.is_create_alb_security_group == false && length(var.alb_aws_security_group_id) == 0 ? file("Variable `alb_aws_security_group_id` is required when `is_create_alb_security_group` is false") : "pass"
  raise_is_public_subnet_ids_empty   = var.is_public_alb && length(var.public_subnet_ids) == 0 ? file("Variable `public_subnet_ids` is required when `is_public_alb` is true") : "pass"
  raise_is_private_subnet_ids_empty  = !var.is_public_alb && length(var.private_subnet_ids) == 0 ? file("Variable `private_subnet_ids` is required when `is_public_alb` is false") : "pass"
  raise_is_http_security             = var.is_ignore_unsecured_connection == false && var.alb_listener_port == 80 ? file("This will expose the alb as public on port http 80") : "pass"
  raise_is_alb_certificate_arn_empty = var.alb_listener_port == 443 && length(var.alb_certificate_arn) == 0 ? file("Variable `alb_certificate_arn` is required when `is_create_alb` is true and `alb_listener_port` == 443") : "pass"
}
