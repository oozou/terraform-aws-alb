# terraform-aws-alb
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.00 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.98.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_application_record"></a> [application\_record](#module\_application\_record) | oozou/route53/aws | 1.0.2 |
| <a name="module_s3_alb_log_bucket"></a> [s3\_alb\_log\_bucket](#module\_s3\_alb\_log\_bucket) | oozou/s3/aws | 1.1.5 |

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.front_end_https_http_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.alb_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.http_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.https_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_service_discovery_private_dns_namespace.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_elb_service_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.alb_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_alb_ingress_rules"></a> [additional\_security\_group\_alb\_ingress\_rules](#input\_additional\_security\_group\_alb\_ingress\_rules) | Map of ingress and any specific/overriding attributes to be created | `any` | `{}` | no |
| <a name="input_additional_security_group_ingress_rules"></a> [additional\_security\_group\_ingress\_rules](#input\_additional\_security\_group\_ingress\_rules) | Map of ingress and any specific/overriding attributes to be created | `any` | `{}` | no |
| <a name="input_alb_access_logs_bucket_name"></a> [alb\_access\_logs\_bucket\_name](#input\_alb\_access\_logs\_bucket\_name) | ALB access\_logs S3 bucket name. | `string` | `""` | no |
| <a name="input_alb_aws_security_group_id"></a> [alb\_aws\_security\_group\_id](#input\_alb\_aws\_security\_group\_id) | (Require) when is\_create\_alb\_security\_group is set to `false` | `string` | `""` | no |
| <a name="input_alb_certificate_arn"></a> [alb\_certificate\_arn](#input\_alb\_certificate\_arn) | Certitificate ARN to link with ALB | `string` | `""` | no |
| <a name="input_alb_listener_port"></a> [alb\_listener\_port](#input\_alb\_listener\_port) | The port to listen on the ALB for public services (80/443, default 443) | `number` | `443` | no |
| <a name="input_alb_s3_access_principals"></a> [alb\_s3\_access\_principals](#input\_alb\_s3\_access\_principals) | n/a | <pre>list(object({<br>    type        = string<br>    identifiers = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_client_keep_alive"></a> [client\_keep\_alive](#input\_client\_keep\_alive) | Client keep alive value in seconds. The valid range is 60-604800 seconds. The default is 3600 seconds. | `number` | `3600` | no |
| <a name="input_default_tg_config"></a> [default\_tg\_config](#input\_default\_tg\_config) | Default configuration values for the target group | <pre>object({<br>    port             = number # The port on which the target group receives traffic<br>    protocol         = string # The protocol used for routing traffic to the targets (HTTP, HTTPS, TCP, etc.)<br>    protocol_version = string # The version of the protocol to use (HTTP1, HTTP2, etc.)<br>    name_max_length  = number # Maximum allowed length for the target group name (AWS limit is 32)<br>    target_type      = string # The type of target (instance, ip, or lambda)<br>    stickiness = optional(object({<br>      cookie_duration = number                           # Time in seconds for the cookie to be considered valid<br>      enabled         = bool                             # Whether stickiness is enabled<br>    }))                                                  # Configuration block for target group stickiness<br>    deregistration_delay              = number           # Time in seconds to wait before deregistering a target<br>    slow_start                        = optional(number) # Time in seconds for slow start mode; optional<br>    load_balancing_algorithm_type     = string           # Algorithm type for load balancing (round_robin, least_outstanding_requests)<br>    load_balancing_anomaly_mitigation = string           # Mitigation mode (off, basic, proactive)<br>  })</pre> | <pre>{<br>  "deregistration_delay": 15,<br>  "load_balancing_algorithm_type": "round_robin",<br>  "load_balancing_anomaly_mitigation": "off",<br>  "name_max_length": 32,<br>  "port": 80,<br>  "protocol": "HTTP",<br>  "protocol_version": "HTTP1",<br>  "slow_start": null,<br>  "stickiness": null,<br>  "target_type": "ip"<br>}</pre> | no |
| <a name="input_default_tg_hc_config"></a> [default\_tg\_hc\_config](#input\_default\_tg\_hc\_config) | Default health check configuration for the target group | <pre>object({<br>    path                = string           # The destination for the health check request<br>    port                = string           # The port to use for the health check<br>    protocol            = optional(string) # The protocol to use for the health check. If not specified, same as the traffic protocol<br>    timeout             = number           # Time to wait in seconds before failing a health check request<br>    healthy_threshold   = number           # Number of consecutive successes required before marking target healthy<br>    unhealthy_threshold = number           # Number of consecutive failures before marking target unhealthy<br>    interval            = number           # Time in seconds between health checks<br>    matcher             = string           # HTTP response codes to indicate a healthy check<br>  })</pre> | <pre>{<br>  "healthy_threshold": 2,<br>  "interval": 15,<br>  "matcher": "200-399",<br>  "path": "/",<br>  "port": "traffic-port",<br>  "protocol": null,<br>  "timeout": 10,<br>  "unhealthy_threshold": 2<br>}</pre> | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). | `bool` | `true` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | (Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment Variable used as a prefix | `string` | n/a | yes |
| <a name="input_fully_qualified_domain_name"></a> [fully\_qualified\_domain\_name](#input\_fully\_qualified\_domain\_name) | The domain name for the ACM cert for attaching to the ALB i.e. *.example.com, www.amazing.com | `string` | `""` | no |
| <a name="input_http_ingress_cidr_blocks"></a> [http\_ingress\_cidr\_blocks](#input\_http\_ingress\_cidr\_blocks) | List of CIDR blocks to allow in HTTP security group | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_http_ingress_prefix_list_ids"></a> [http\_ingress\_prefix\_list\_ids](#input\_http\_ingress\_prefix\_list\_ids) | inbound or outbound rules to allow or deny traffic to/from specific AWS-managed services like S3, DynamoDB | `list(string)` | `[]` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | The port for the HTTP listener | `number` | `80` | no |
| <a name="input_https_ingress_cidr_blocks"></a> [https\_ingress\_cidr\_blocks](#input\_https\_ingress\_cidr\_blocks) | List of CIDR blocks to allow in HTTPS security group | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_https_ingress_prefix_list_ids"></a> [https\_ingress\_prefix\_list\_ids](#input\_https\_ingress\_prefix\_list\_ids) | inbound or outbound rules to allow or deny traffic to/from specific AWS-managed services like S3, DynamoDB | `list(string)` | `[]` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | The port for the HTTPS listener | `number` | `443` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | The time in seconds that the connection is allowed to be idle | `number` | `60` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | The type of IP addresses used by the subnets for your load balancer. The possible values are `ipv4` and `dualstack`. | `string` | `"ipv4"` | no |
| <a name="input_is_create_alb_dns_record"></a> [is\_create\_alb\_dns\_record](#input\_is\_create\_alb\_dns\_record) | Whether to create ALB dns record or not | `bool` | `true` | no |
| <a name="input_is_create_alb_security_group"></a> [is\_create\_alb\_security\_group](#input\_is\_create\_alb\_security\_group) | Whether to create ALB security group or not | `bool` | `true` | no |
| <a name="input_is_create_discovery_namespace"></a> [is\_create\_discovery\_namespace](#input\_is\_create\_discovery\_namespace) | Flag to determine whether to create a discovery namespace | `bool` | `false` | no |
| <a name="input_is_default_target_group_enabled"></a> [is\_default\_target\_group\_enabled](#input\_is\_default\_target\_group\_enabled) | Flag to enable or disable the default target group | `bool` | `false` | no |
| <a name="input_is_enable_access_log"></a> [is\_enable\_access\_log](#input\_is\_enable\_access\_log) | Boolean to enable / disable access\_logs. Defaults to false, even when bucket is specified. | `bool` | `false` | no |
| <a name="input_is_ignore_unsecured_connection"></a> [is\_ignore\_unsecured\_connection](#input\_is\_ignore\_unsecured\_connection) | Whether to by pass the HTTPs endpoints required or not | `bool` | `false` | no |
| <a name="input_is_public_alb"></a> [is\_public\_alb](#input\_is\_public\_alb) | Flag for Internal/Public ALB. ALB is production env should be public | `bool` | `false` | no |
| <a name="input_listener_https_fixed_response"></a> [listener\_https\_fixed\_response](#input\_listener\_https\_fixed\_response) | Have the HTTPS listener return a fixed response for the default action. | <pre>object({<br>    content_type = string<br>    message_body = string<br>    status_code  = string<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the alb to create | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix name of customer to be displayed in AWS console and resource | `string` | n/a | yes |
| <a name="input_preserve_host_header"></a> [preserve\_host\_header](#input\_preserve\_host\_header) | Indicates whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change. | `bool` | `false` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnets for private alb | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnets for public AWS Application Load Balancer deployment | `list(string)` | `[]` | no |
| <a name="input_route53_hosted_zone_name"></a> [route53\_hosted\_zone\_name](#input\_route53\_hosted\_zone\_name) | The domain name in Route53 to fetch the hosted zone, i.e. example.com, mango-dev.blue.cloud | `string` | `""` | no |
| <a name="input_s3_alb_log_bucket_lifecycle_rules"></a> [s3\_alb\_log\_bucket\_lifecycle\_rules](#input\_s3\_alb\_log\_bucket\_lifecycle\_rules) | List of lifecycle rules to transition the data. Leave empty to disable this feature. storage\_class can be STANDARD\_IA, ONEZONE\_IA, INTELLIGENT\_TIERING, GLACIER, or DEEP\_ARCHIVE | `any` | `[]` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | The SSL policy for the ALB listener when using HTTPS | `string` | `"ELBSecurityPolicy-2016-08"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys | `map(any)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC to deploy the alb in | `string` | n/a | yes |
| <a name="input_xff_header_processing_mode"></a> [xff\_header\_processing\_mode](#input\_xff\_header\_processing\_mode) | The mode for processing the X-Forwarded-For header. The possible values are `append` and `preserve`. The default is `append`. | `string` | `"append"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of alb |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_alb_id"></a> [alb\_id](#output\_alb\_id) | ID of alb |
| <a name="output_alb_listener_http_arn"></a> [alb\_listener\_http\_arn](#output\_alb\_listener\_http\_arn) | ARN of the listener (matches id). |
| <a name="output_alb_listener_https_redirect_arn"></a> [alb\_listener\_https\_redirect\_arn](#output\_alb\_listener\_https\_redirect\_arn) | ARN of the listener (matches id). |
| <a name="output_alb_sg_id"></a> [alb\_sg\_id](#output\_alb\_sg\_id) | The security group id of the ALB |
| <a name="output_service_discovery_namespace"></a> [service\_discovery\_namespace](#output\_service\_discovery\_namespace) | The ID of a namespace. |
<!-- END_TF_DOCS -->