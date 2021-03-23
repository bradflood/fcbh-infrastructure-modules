#reference: https://engineering.resolvergroup.com/2020/12/setting-up-athena-to-analyse-cloudfront-access-logs/ 

terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
  required_version = "~> 0.12"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      version = "~> 2.70"
    }
  }
}



# resource "aws_s3_bucket" "cloudfront_logs_bucket" {
#   bucket = "cloudfront-logs"
 
#   lifecycle_rule {
#     id      = "cloudfront_logs_lifecycle_rule"
#     enabled = true
 
#     expiration {
#       days = 365
#     }
#   }
# }
 
data "aws_s3_bucket" "cloudfront_logs_bucket" {
  bucket = "dbp-log"
}

# resource "aws_cloudfront_distribution" "cloudfront_cdn" {
# ...
 
#   logging_config {
#     bucket = aws_s3_bucket.cloudfront_logs_bucket.bucket_domain_name
#     prefix = "main/"
#   }
 
# ...
# }


resource "aws_s3_bucket" "cloudfront_logs_athena_results_bucket" {
  bucket = "cloudfront-logs-athena-results"
 
  lifecycle_rule {
    id      = "cloudfront_logs_athena_results_lifecycle_rule"
    enabled = true
 
    expiration {
      days = 365
    }
  }
}

resource "aws_athena_database" "cloudfront_logs_athena_database" {
  name   = "cloudfront_logs"
  bucket = aws_s3_bucket.cloudfront_logs_athena_results_bucket.bucket
}
 
resource "aws_athena_workgroup" "cloudfront_logs_athena_workgroup" {
  name        = "cloudfront_logs_workgroup"
  description = "Workgroup for Athena queries on CloudFront access logs"
 
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
 
    result_configuration {
      output_location = "s3://${aws_s3_bucket.cloudfront_logs_athena_results_bucket.bucket}/output/"
 
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

resource "null_resource" "cloudfront_logs_athena_table" {
  triggers = {
    athena_database       = aws_athena_database.cloudfront_logs_athena_database.id
    athena_results_bucket = aws_s3_bucket.cloudfront_logs_athena_results_bucket.id
  }
 
  provisioner "local-exec" {
    environment = {
      AWS_REGION = eu-west-2
    }
 
    command = <<-EOF
aws athena start-query-execution --query-string file://create_table_main.sql --output json --query-execution-context Database=${self.triggers.athena_database} --result-configuration OutputLocation=s3://${self.triggers.athena_results_bucket}
    EOF
  }
 
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOF
aws athena start-query-execution --query-string 'DROP TABLE IF EXISTS cloudfront_logs.cloudfront_logs' --output json --query-execution-context Database=${self.triggers.athena_database} --result-configuration OutputLocation=s3://${self.triggers.athena_results_bucket}
    EOF
  }
}