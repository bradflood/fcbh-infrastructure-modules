

variable "redirect_to_host" { }
variable "redirect_to_port" { }
variable "redirect_to_path" { }
variable "alb_name" { }
variable "certificate_arn" {
    description="at most one certificate can be directly attached to the alb"
 }
variable "certificate_arn2" { 
    description="use this if a second certificate is to be associated with the alb"
}
variable "security_groups" {
  type = list(string)
}
variable "subnets" {
  type = list(string)
}
variable "host_header_values" {
  type = list(string)
}