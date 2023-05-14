###############################################################################
# Outputs - Application Load Balancer
###############################################################################
output "ecs_alb_dns" {
  description = "The DNS name of the ECS load balancer."
  value       = module.alb.lb_dns_name
}

output "streaming_server_alb_dns" {
  description = "The DNS name of the Streaming Server load balancer."
  value       = aws_lb.streaming_server.dns_name
}

###############################################################################
# Outputs - Bastion Public IP
###############################################################################
output "bastion_public_ip" {
  description = "The public IP address assigned to the Bastion instance."
  value       = module.bastion.public_ip
}
