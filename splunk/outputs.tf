output "splunk_password" {
  description = "Username:admin Password below for Splunk Instance"
  value = aws_instance.splunk_ami.id
}

output "splunk_search_head_ip" {
    value = aws_instance.prod_search_head.private_ip
}
