terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
   required_version = ">= 0.13"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

# module "notify_slack" {
#   source            = "git::https://github.com/cloudposse/terraform-aws-sns-lambda-notify-slack?ref=tags/0.3.0"
#   namespace         = var.namespace
#   stage             = var.stage
#   name              = var.name
#   sns_topic_name    = var.sns_topic_name
#   slack_webhook_url = var.slack_webhook_url
#   slack_channel     = var.slack_channel
#   slack_username    = var.slack_username
# }

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "my-dashboard"

  dashboard_body = <<EOF
 {
    "widgets": [
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.application_elb_id, { "id": "m1" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "title": "HTTP Request Count",
                "period": 1,
                "stat": "Sum",
                "legend": {
                    "position": "hidden"
                }
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", "app/awseb-AWSEB-3OCD3L7FY5PQ/69e0bed302bd3994", { "color": "#2ca02c", "label": "2xx" } ],
                    [ ".", "HTTPCode_Target_3XX_Count", ".", ".", { "label": "3xx", "color": "#1f77b4" } ],
                    [ ".", "HTTPCode_Target_4XX_Count", ".", ".", { "color": "#ff7f0e", "label": "4xx" } ],
                    [ ".", "HTTPCode_Target_5XX_Count", ".", ".", { "label": "5xx" } ],
                    [ ".", "HTTPCode_ELB_4XX_Count", ".", ".", { "color": "#ffbb78", "label": "ELB 4xx" } ],
                    [ ".", "HTTPCode_ELB_5XX_Count", ".", ".", { "color": "#ff9896", "label": "ELB 5xx" } ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "us-west-2",
                "stat": "Sum",
                "period": 60,
                "title": "HTTP Code Stack"
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "ActiveConnectionCount", "LoadBalancer", "app/awseb-AWSEB-3OCD3L7FY5PQ/69e0bed302bd3994" ],
                    [ ".", "NewConnectionCount", ".", "." ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "stat": "Sum",
                "period": 60,
                "title": "HTTP Connections"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "awseb-e-4xsksmacs3-stack-AWSEBAutoScalingGroup-1IDMGH0LQUSME", { "label": "EC2 (Avg)" } ],
                    [ "AWS/RDS", ".", "DBClusterIdentifier", "prod-cluster", { "label": "RDS" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "stat": "Average",
                "period": 60,
                "title": "CPU Usage",
                "legend": {
                    "position": "bottom"
                },
                "yAxis": {
                    "left": {
                        "min": 0,
                        "max": 100
                    }
                }
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 12,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "DatabaseConnections", "DBClusterIdentifier", "prod-cluster" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "stat": "Sum",
                "period": 60,
                "legend": {
                    "position": "hidden"
                },
                "title": "DB Connections",
                "annotations": {
                    "horizontal": [
                        {
                            "label": "Per-Server Limit",
                            "value": 90
                        }
                    ]
                }
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "FreeableMemory", "DBClusterIdentifier", "prod-cluster" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "stat": "Average",
                "period": 60,
                "title": "DB Free Memory",
                "legend": {
                    "position": "hidden"
                },
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                }
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", "app/awseb-AWSEB-3OCD3L7FY5PQ/69e0bed302bd3994", { "color": "#ff7f0e", "id": "m1", "label": "Target 4xx" } ],
                    [ ".", "HTTPCode_Target_5XX_Count", ".", ".", { "color": "#d62728", "id": "m2", "label": "Target 5xx" } ],
                    [ ".", "HTTPCode_ELB_4XX_Count", ".", ".", { "color": "#1f77b4", "id": "m3", "label": "ELB 4xx" } ],
                    [ ".", "HTTPCode_ELB_5XX_Count", ".", ".", { "color": "#9467bd", "id": "m4", "label": "ELB 5xx" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "stat": "Sum",
                "period": 60,
                "title": "HTTP Errors",
                "yAxis": {
                    "left": {
                        "label": "Count",
                        "showUnits": false,
                        "min": 0
                    }
                }
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 12,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "app/awseb-AWSEB-3OCD3L7FY5PQ/69e0bed302bd3994", { "stat": "Maximum", "label": "Maximum", "color": "#d62728", "yAxis": "right" } ],
                    [ "...", { "stat": "p99", "label": "p99" } ],
                    [ "...", { "stat": "p95", "label": "p95" } ],
                    [ "...", { "color": "#1f77b4", "label": "Average" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "stat": "Average",
                "period": 60,
                "title": "HTTP Response Time",
                "yAxis": {
                    "left": {
                        "min": 0
                    },
                    "right": {
                        "min": 0
                    }
                }
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "LoginFailures", "Role", "WRITER", "DBClusterIdentifier", "prod-cluster" ],
                    [ "...", "READER", ".", "." ]
                ],
                "region": "us-west-2",
                "title": "RDS LoginFailures"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ElasticBeanstalk", "EnvironmentHealth", "EnvironmentName", "dbp-zing" ]
                ],
                "region": "us-west-2",
                "title": "Beanstalk EnvironmentHealth"
            }
        }
    ]
}
 EOF
}
