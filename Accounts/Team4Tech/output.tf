output "jenkins_cname_record" {
  description = "CNAME record for Jenkins"
  value       = aws_route53_record.jenkins_cname.name
}
