variable "environment" {
  type = string
}

variable "s3_buckets" {
  type = list(string)
}

variable "elastictranscoder_arns" {
  type = list(string)
}

variable "lambda_function_arns" {
  type = list(string)
}
