
# output "arn" {
#   value       = module.sns
#   description = "SNS Topic ARN"
# }

output "topic_name" {
  value       = module.sns.outputs.sns_topic
  description = "SNS Topic Name"
}