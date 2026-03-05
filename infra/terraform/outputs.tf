output "render_node_public_ips" {
  value = [for i in aws_instance.render_node : i.public_ip]
}
