output "vpn_instance" {
  description = "VPN Instance"
  value       = aws_instance.openvpn
}

output "ssh_sg" {
  description = "SSH Security Group"
  value       = aws_security_group.secure_ssh
}
