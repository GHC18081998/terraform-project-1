locals {
  # Network Constants
  anywhere_cidr = ["0.0.0.0/0"]
  
  # Protocol Constants
  tcp_protocol  = "tcp"
  http_protocol = "HTTP"
  all_protocols = "-1"
  
  # Load Balancer Constants
  alb_type      = "application"
}
