resource "aws_s3_bucket" "s3_upload" {
  bucket = "dbp-etl-upload-${var.environment}-${random_string.random.result}"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["POST", "PUT", "GET"]
    allowed_origins = ["*"]
    expose_headers = [
      "Content-Length",
      "Content-Type",
      "Connection",
      "Date",
      "ETag",
      "Server",
    ]
  }
}

resource "aws_s3_bucket_policy" "s3_dbs_access" {
  bucket = aws_s3_bucket.s3_upload.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::869054869504:root"
        },
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.s3_upload.arn
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::869054869504:root"
        },
        Action   = ["s3:Get*", "s3:Delete*"]
        Resource = "${aws_s3_bucket.s3_upload.arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::869054869504:root"
        },
        Action   = "s3:Put*"
        Resource = "${aws_s3_bucket.s3_upload.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# resource "aws_s3_bucket_policy" "s3_upload" {
#   bucket = aws_s3_bucket.s3_upload.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = "s3:ListBucket"
#         Principal = {
#           AWS = "arn:aws:iam::078432969830:role/transcoding-api-transcoding-api-get-input-files-w9gxhplj7q9mju3h"
#         }
#         Resource = aws_s3_bucket.s3_upload.arn
#       },
#       {
#         Effect = "Allow"
#         Action = ["s3:GetObject", "s3:PutObject"]
#         Principal = {
#           AWS = "arn:aws:iam::078432969830:role/transcoding-api-transcoding-api-transcode-w9gxhplj7q9mju3h"
#         }
#         Resource = "${aws_s3_bucket.s3_upload.arn}/*"
#       }
#     ]
#   })
# }

resource "aws_s3_bucket_object" "s3_lpts" {
  bucket = aws_s3_bucket.s3_upload.id
  key    = "qry_dbp4_Regular_and_NonDrama.xml"
}
