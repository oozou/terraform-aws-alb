/* -------------------------------------------------------------------------- */
/*                                   Generic                                  */
/* -------------------------------------------------------------------------- */
variable "name" {
  description = "Name of the alb to create"
  type        = string
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

variable "prefix" {
  description = "The prefix name of customer to be displayed in AWS console and resource"
  type        = string
}

variable "tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys"
  type        = map(any)
  default     = {}
}


/* -------------------------------------------------------------------------- */
/*                               Security Group                               */
/* -------------------------------------------------------------------------- */
variable "additional_security_group_ingress_rules" {
  description = "Map of ingress and any specific/overriding attributes to be created"
  type        = any
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                                     VPC                                    */
/* -------------------------------------------------------------------------- */
variable "vpc_id" {
  description = "VPC to deploy the alb in"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for public AWS Application Load Balancer deployment"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Private subnets for private alb"
  type        = list(string)
  default     = []
}

/* -------------------------------------------------------------------------- */
/*                               Security Group                               */
/* -------------------------------------------------------------------------- */

variable "is_create_alb_security_group" {
  description = "Whether to create ALB security group or not"
  type        = bool
  default     = true
}

variable "alb_aws_security_group_id" {
  description = "(Require) when is_create_alb_security_group is set to `false`"
  type        = string
  default     = ""
}

variable "additional_security_group_alb_ingress_rules" {
  description = "Map of ingress and any specific/overriding attributes to be created"
  type        = any
  default     = {}
}

variable "http_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allow in HTTP security group"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]

  validation {
    condition     = alltrue([for cidr in var.http_ingress_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "Each entry in http_ingress_cidr_blocks must be a valid CIDR block."
  }
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for ALB `ipv4` and `dualstack`."
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "ip_address_type must be either `ipv4` or `dualstack`."
  }
}

variable "https_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allow in HTTPS security group"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]

  validation {
    condition     = alltrue([for cidr in var.https_ingress_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "Each entry in https_ingress_cidr_blocks must be a valid CIDR block."
  }
}

variable "http_port" {
  description = "The port for the HTTP listener"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "The port for the HTTPS listener"
  type        = number
  default     = 443
}

variable "http_ingress_prefix_list_ids" {
  description = "inbound or outbound rules to allow or deny traffic to/from specific AWS-managed services like S3, DynamoDB"
  type        = list(string)
  default     = []
}

variable "https_ingress_prefix_list_ids" {
  description = "inbound or outbound rules to allow or deny traffic to/from specific AWS-managed services like S3, DynamoDB"
  type        = list(string)
  default     = []
}
/* -------------------------------------------------------------------------- */
/*                                     ALB                                    */
/* -------------------------------------------------------------------------- */
variable "is_public_alb" {
  description = "Flag for Internal/Public ALB. ALB is production env should be public"
  type        = bool
  default     = false
}

variable "is_ignore_unsecured_connection" {
  description = "Whether to by pass the HTTPs endpoints required or not"
  type        = bool
  default     = false
}

variable "alb_listener_port" {
  description = "The port to listen on the ALB for public services (80/443, default 443)"
  type        = number
  default     = 443
}

variable "alb_certificate_arn" {
  description = "Certitificate ARN to link with ALB"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = bool
  default     = false
}

variable "ssl_policy" {
  description = "The SSL policy for the ALB listener when using HTTPS"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "is_enable_access_log" {
  description = "Boolean to enable / disable access_logs. Defaults to false, even when bucket is specified."
  type        = bool
  default     = false
}

variable "s3_alb_log_bucket_lifecycle_rules" {
  description = "List of lifecycle rules to transition the data. Leave empty to disable this feature. storage_class can be STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, or DEEP_ARCHIVE"
  type        = any
  default     = []
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are `ipv4` and `dualstack`."
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "dualstack", "dualstack-without-public-ipv4"], var.ip_address_type)
    error_message = "ip_address_type must be either `ipv4` or `dualstack` or `dualstack-without-public-ipv4`."
  }
}

variable "drop_invalid_header_fields" {
  description = "Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false)."
  type        = bool
  default     = true
}

variable "preserve_host_header" {
  description = "Indicates whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change."
  type        = bool
  default     = false
}

variable "xff_header_processing_mode" {
  description = "The mode for processing the X-Forwarded-For header. The possible values are `append` and `preserve`. The default is `append`."
  type        = string
  default     = "append"
}

variable "client_keep_alive" {
  description = "Client keep alive value in seconds. The valid range is 60-604800 seconds. The default is 3600 seconds."
  type        = number
  default     = 3600
}

variable "is_default_target_group_enabled" {
  description = "Flag to enable or disable the default target group"
  type        = bool
  default     = false
}

variable "default_tg_config" {
  description = "Default configuration values for the target group"

  type = object({
    port             = number # The port on which the target group receives traffic
    protocol         = string # The protocol used for routing traffic to the targets (HTTP, HTTPS, TCP, etc.)
    protocol_version = string # The version of the protocol to use (HTTP1, HTTP2, etc.)
    name_max_length  = number # Maximum allowed length for the target group name (AWS limit is 32)
    target_type      = string # The type of target (instance, ip, or lambda)
    stickiness = optional(object({
      cookie_duration = number                           # Time in seconds for the cookie to be considered valid
      enabled         = bool                             # Whether stickiness is enabled
    }))                                                  # Configuration block for target group stickiness
    deregistration_delay              = number           # Time in seconds to wait before deregistering a target
    slow_start                        = optional(number) # Time in seconds for slow start mode; optional
    load_balancing_algorithm_type     = string           # Algorithm type for load balancing (round_robin, least_outstanding_requests)
    load_balancing_anomaly_mitigation = string           # Mitigation mode (off, basic, proactive)
  })

  default = {
    port                              = 80            # The port on which the target group receives traffic
    protocol                          = "HTTP"        # The protocol used for routing traffic
    protocol_version                  = "HTTP1"       # The protocol version used
    name_max_length                   = 32            # Maximum allowed target group name length
    target_type                       = "ip"          # The type of targets registered
    stickiness                        = null          # No stickiness enabled by default
    deregistration_delay              = 15            # Delay before deregistering a target
    slow_start                        = null          # No slow start configured by default
    load_balancing_algorithm_type     = "round_robin" # Load balancing method
    load_balancing_anomaly_mitigation = "off"         # Anomaly mitigation disabled
  }
}


variable "default_tg_hc_config" {
  description = "Default health check configuration for the target group"

  type = object({
    path                = string           # The destination for the health check request
    port                = string           # The port to use for the health check
    protocol            = optional(string) # The protocol to use for the health check. If not specified, same as the traffic protocol
    timeout             = number           # Time to wait in seconds before failing a health check request
    healthy_threshold   = number           # Number of consecutive successes required before marking target healthy
    unhealthy_threshold = number           # Number of consecutive failures before marking target unhealthy
    interval            = number           # Time in seconds between health checks
    matcher             = string           # HTTP response codes to indicate a healthy check
  })

  default = {
    path                = "/"            # The destination for the health check request
    port                = "traffic-port" # The port to use for the health check
    protocol            = null           # The protocol to use for the health check
    timeout             = 10             # Time to wait in seconds before failing a health check request
    healthy_threshold   = 2              # Number of successes before marking target healthy
    unhealthy_threshold = 2              # Number of failures before marking target unhealthy
    interval            = 15             # Time in seconds between health checks
    matcher             = "200-399"      # HTTP response codes that indicate a healthy check
  }
}

variable "listener_https_fixed_response" {
  description = "Have the HTTPS listener return a fixed response for the default action."
  type = object({
    content_type = string
    message_body = string
    status_code  = string
  })
  default = null
}

/* -------------------------------------------------------------------------- */
/*                                     DNS                                    */
/* -------------------------------------------------------------------------- */
variable "is_create_alb_dns_record" {
  description = "Whether to create ALB dns record or not"
  type        = bool
  default     = true
}

variable "route53_hosted_zone_name" {
  description = "The domain name in Route53 to fetch the hosted zone, i.e. example.com, mango-dev.blue.cloud"
  type        = string
  default     = ""
}

variable "fully_qualified_domain_name" {
  description = "The domain name for the ACM cert for attaching to the ALB i.e. *.example.com, www.amazing.com"
  type        = string
  default     = ""
}