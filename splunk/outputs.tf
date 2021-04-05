output "splunk_password" {
  description = "Username:admin Password below for Splunk Search Head Instance"
  value = aws_instance.prod_search_head.id
}

output "splunk_search_head_ip" {
    value = aws_instance.prod_search_head.private_ip
}
