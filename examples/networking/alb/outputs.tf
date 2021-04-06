output "alb_dns_name" {
  value = module.my-alb.alb_dns_name
  description = "The domain name of the load balancer"
}