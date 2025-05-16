/* -------------------------------------------------------------------------- */
/*                             ALB Security Group                             */
/* -------------------------------------------------------------------------- */
resource "aws_security_group" "alb" {
  count = var.is_create_alb_security_group ? 1 : 0

  name        = format("%s-alb-sg", local.alb_name)
  description = format("Security group for ALB %s-alb", local.alb_name)
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { "Name" = format("%s-alb-sg", local.alb_name) })
}

resource "aws_security_group_rule" "http_ingress" {
  count             = var.is_create_alb_security_group ? 1 : 0
  type              = "ingress"
  from_port         = var.http_port
  to_port           = var.http_port
  protocol          = "tcp"
  cidr_blocks       = local.http_ingress_cidr_blocks_v4
  ipv6_cidr_blocks  = local.http_ingress_cidr_blocks_v6
  prefix_list_ids   = var.http_ingress_prefix_list_ids
  security_group_id = aws_security_group.alb[0].id
}

resource "aws_security_group_rule" "https_ingress" {
  count             = var.is_create_alb_security_group ? 1 : 0
  type              = "ingress"
  from_port         = var.https_port
  to_port           = var.https_port
  protocol          = "tcp"
  cidr_blocks       = local.https_ingress_cidr_blocks_v4
  ipv6_cidr_blocks  = local.https_ingress_cidr_blocks_v6
  prefix_list_ids   = var.https_ingress_prefix_list_ids
  security_group_id = aws_security_group.alb[0].id
}

resource "aws_security_group_rule" "alb_ingress" {
  for_each = var.additional_security_group_alb_ingress_rules

  type              = "ingress"
  from_port         = lookup(each.value, "from_port", lookup(each.value, "port", null))
  to_port           = lookup(each.value, "to_port", lookup(each.value, "port", null))
  protocol          = lookup(each.value, "protocol", null)
  security_group_id = aws_security_group.alb[0].id

  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  description              = lookup(each.value, "description", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}

/* -------------------------------------------------------------------------- */
/*                                     ALB                                    */
/* -------------------------------------------------------------------------- */
# Define the routing for the workloads
# Application Load Balancer Creation (ALB) in the DMZ
resource "aws_lb" "this" {
  name                       = var.is_public_alb ? format("%s-alb", local.alb_name) : format("%s-internal-alb", local.alb_name)
  load_balancer_type         = "application"
  internal                   = !var.is_public_alb
  subnets                    = var.is_public_alb ? var.public_subnet_ids : var.private_subnet_ids
  security_groups            = [local.alb_aws_security_group_id]
  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = var.idle_timeout
  ip_address_type            = var.ip_address_type
  drop_invalid_header_fields = var.drop_invalid_header_fields
  preserve_host_header       = var.preserve_host_header
  xff_header_processing_mode = var.xff_header_processing_mode
  client_keep_alive          = var.client_keep_alive

  access_logs {
    bucket  = var.alb_access_logs_bucket_name != "" ? var.alb_access_logs_bucket_name : try(module.s3_alb_log_bucket[0].bucket_name, null)
    prefix  = "${local.alb_name}-alb"
    enabled = var.is_enable_access_log
  }

  tags = merge(local.tags, { "Name" : var.is_public_alb ? format("%s-alb", local.alb_name) : format("%s-internal-alb", local.alb_name) })
}

resource "aws_lb_target_group" "this" {
  count                             = var.is_default_target_group_enabled ? 1 : 0
  name                              = substr(format("%s-tg", local.alb_name), 0, var.default_tg_config.name_max_length)
  port                              = var.default_tg_config.port
  protocol                          = var.default_tg_config.protocol
  protocol_version                  = var.default_tg_config.protocol_version
  vpc_id                            = var.vpc_id
  target_type                       = var.default_tg_config.target_type
  load_balancing_algorithm_type     = var.default_tg_config.load_balancing_algorithm_type
  load_balancing_anomaly_mitigation = var.default_tg_config.load_balancing_anomaly_mitigation
  deregistration_delay              = var.default_tg_config.deregistration_delay
  slow_start                        = var.default_tg_config.slow_start

  health_check {
    protocol            = var.default_tg_hc_config.protocol != null ? var.default_tg_hc_config.protocol : var.default_tg_hc_config.protocol
    path                = var.default_tg_hc_config.path
    port                = var.default_tg_hc_config.port
    timeout             = var.default_tg_hc_config.timeout
    healthy_threshold   = var.default_tg_hc_config.healthy_threshold
    unhealthy_threshold = var.default_tg_hc_config.unhealthy_threshold
    interval            = var.default_tg_hc_config.interval
    matcher             = var.default_tg_hc_config.matcher
  }

  dynamic "stickiness" {
    for_each = var.default_tg_config.stickiness == null ? [] : [var.default_tg_config.stickiness]
    content {
      type            = "lb_cookie"
      cookie_duration = stickiness.value.cookie_duration
      enabled         = var.default_tg_config.protocol == "TCP" ? false : stickiness.value.enabled
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.tags,
    {
      Name = format("%s-tg", local.alb_name)
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.id

  port            = var.alb_listener_port
  protocol        = var.alb_listener_port == 443 ? "HTTPS" : "HTTP"
  certificate_arn = var.alb_listener_port == 443 ? var.alb_certificate_arn : ""
  ssl_policy      = var.alb_listener_port == 443 ? var.ssl_policy : ""


  default_action {
    target_group_arn = var.listener_https_fixed_response != null ? null : aws_lb_target_group.this[0].arn
    type             = var.listener_https_fixed_response != null ? "fixed-response" : "forward"

    dynamic "fixed_response" {
      for_each = var.listener_https_fixed_response != null ? [var.listener_https_fixed_response] : []
      content {
        content_type = fixed_response.value["content_type"]
        message_body = fixed_response.value["message_body"]
        status_code  = fixed_response.value["status_code"]
      }
    }
  }
}

resource "aws_lb_listener" "front_end_https_http_redirect" {
  # If not var.alb_listener_port == 443, the listener rule will overlap and raise error
  count = var.alb_listener_port == 443 ? 1 : 0

  depends_on = [
    aws_lb_listener.http
  ]

  load_balancer_arn = aws_lb.this.id

  port     = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

/* -------------------------------------------------------------------------- */
/*                              ALB Access Log Bucket                         */
/* -------------------------------------------------------------------------- */

data "aws_elb_service_account" "this" {
  count = var.alb_s3_access_principals == [] ? 1 : 0
}

data "aws_iam_policy_document" "alb_log" {
  count = var.alb_access_logs_bucket_name != "" && var.is_enable_access_log ? 1 : 0
  statement {
    sid    = "AllowALBServicePrincipal"
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = ["${module.s3_alb_log_bucket[0].bucket_arn}/*"]

    dynamic "principals" {
      for_each = length(var.alb_s3_access_principals) > 0 ? var.alb_s3_access_principals : [{
        type        = "AWS"
        identifiers = data.aws_elb_service_account.this[*].arn
      }]
      content {
        type        = principals.value.type
        identifiers = principals.value.identifiers
      }
    }
  }
}

module "s3_alb_log_bucket" {
  source  = "oozou/s3/aws"
  version = "1.1.5"
  count   = var.alb_access_logs_bucket_name != "" && var.is_enable_access_log ? 1 : 0

  prefix      = var.prefix
  environment = var.environment
  bucket_name = format("%s-alb-log-bucket", var.name)

  versioning_enabled            = false
  is_enable_s3_hardening_policy = false
  is_use_kms_managed_key        = false

  additional_bucket_polices = [data.aws_iam_policy_document.alb_log[0].json]
  lifecycle_rules           = var.s3_alb_log_bucket_lifecycle_rules

  tags = local.tags
}

/* -------------------------------------------------------------------------- */
/*                                     DNS                                    */
/* -------------------------------------------------------------------------- */
# Setup DNS discovery
resource "aws_service_discovery_private_dns_namespace" "internal" {
  # This name does not follow convention because it is used as part of the domain name
  count = var.is_create_discovery_namespace ? 1 : 0
  name        = "${local.alb_name}.internal"
  description = "Service Discovery for internal communcation"
  vpc         = var.vpc_id

  tags = merge(local.tags, { "Name" : format("%s.internal", local.alb_name) })
}

# /* --------------------------------- Route53 -------------------------------- */
module "application_record" {
  source  = "oozou/route53/aws"
  version = "1.0.2"

  count = var.is_public_alb && var.is_create_alb_dns_record ? 1 : 0

  is_create_zone = false
  is_public_zone = true # Default `true`

  prefix      = var.prefix
  environment = var.environment

  dns_name = var.route53_hosted_zone_name

  dns_records = {
    application_record = {
      name = replace(var.fully_qualified_domain_name, ".${var.route53_hosted_zone_name}", "") # Auto append with dns_name
      type = "A"

      alias = {
        name                   = aws_lb.this.dns_name # Target DNS name
        zone_id                = aws_lb.this.zone_id
        evaluate_target_health = true
      }
    }
  }
}
