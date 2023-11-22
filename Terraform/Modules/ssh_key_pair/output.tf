output "key_name" {
  description = "SSH Key Pair"
  value       = aws_key_pair.ssh_key_pair.key_name
}
