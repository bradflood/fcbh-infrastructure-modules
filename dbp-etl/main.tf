terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  required_version = ">= 0.13"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_ecs_cluster" "main" {
  name = "dbp-etl-${var.environment}-${random_string.random.result}"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "dbp-etl-${var.environment}"
  task_role_arn            = aws_iam_role.iam_task.arn
  execution_role_arn       = aws_iam_role.iam_execution.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  volume {
    name = "efs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.main.id
    }
  }

  container_definitions = jsonencode([{
    name  = "dbp-etl"
    image = "${aws_ecr_repository.main.repository_url}:latest"
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.main.name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "dbp-etl"
      }
    }
    mountPoints = [{
      sourceVolume  = "efs"
      containerPath = "/efs"
    }]
    environment = [
      {
        name  = "UPLOAD_BUCKET"
        value = aws_s3_bucket.s3_upload.id
      },
      {
        name  = "DATABASE_USER"
        value = var.database_user
      },
      {
        name  = "DATABASE_PASSWD"
        value = var.database_passwd
      },
      {
        name  = "DATABASE_USER_DB_NAME"
        value = var.database_user_db_name
      },
      {
        name  = "DATABASE_HOST"
        value = var.database_host
      },
      {
        name  = "DATABASE_PORT"
        value = var.database_port
      },
      {
        name  = "DATABASE_DB_NAME"
        value = var.database_db_name
      },
      {
        name  = "S3_BUCKET"
        value = var.s3_bucket
      },
      {
        name  = "S3_VID_BUCKET"
        value = var.s3_vid_bucket
      },
      {
        name  = "S3_ARTIFACTS_BUCKET"
        value = var.s3_artifacts_bucket
      },
      {
        name  = "ASSUME_ROLE_ARN"
        value = var.assume_role_arn
      },
    ]
  }])
}

resource "aws_efs_file_system" "main" {
  creation_token = "dbp-etl-${var.environment}-${random_string.random.result}"
}

resource "aws_efs_mount_target" "main" {
  for_each        = toset(var.ecs_subnets)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.key
  security_groups = [aws_security_group.main.id]
}

data "aws_subnet" "main" {
  for_each = toset(var.ecs_subnets)
  id       = each.key
}

resource "aws_security_group" "main" {
  vpc_id = data.aws_subnet.main[var.ecs_subnets[0]].vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [for s in data.aws_subnet.main : s.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "main" {
  name = "dbp-etl-${var.environment}-${random_string.random.result}"
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/dbp-etl-${var.environment}-${random_string.random.result}"
  retention_in_days = 7
}
