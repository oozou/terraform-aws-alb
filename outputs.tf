output "alb_arn" {
  description = "ARN of alb"
  value       = try(aws_lb.this[0].arn, "")
}

output "alb_id" {
  description = "ID of alb"
  value       = try(aws_lb.this[0].id, "")
}

output "alb_listener_http_arn" {
  description = "ARN of the listener (matches id)."
  value       = try(aws_lb_listener.http[0].arn, "")
}

output "alb_listener_https_redirect_arn" {
  description = "ARN of the listener (matches id)."
  value       = try(aws_lb_listener.front_end_https_http_redirect[0].arn, "")
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = try(aws_lb.this[0].dns_name, "")
}

output "alb_sg_id" {
  description = "The security group id of the ALB"
  value       = try(aws_security_group.alb[0].id, "")
}