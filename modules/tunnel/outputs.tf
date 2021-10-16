output "tunnel_server" {
  value = aws_instance.tunnel.public_dns
}