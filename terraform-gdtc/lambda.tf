data "aws_ecr_repository" "gdtc-image_ecr_repo" {
  name = "gdtc-image"
}

resource "aws_s3_bucket" "gdtc-task-bucket" {
    bucket = "gdtc-task-bucket"
    tags = {
      Name = "GDTC Bucket"
    }
}

resource "aws_lambda_function" "s3_to_rds_function" {
  function_name = "s3_to_rds"
  timeout       = 5 # seconds
  image_uri     = "${data.aws_ecr_repository.gdtc-image_ecr_repo.repository_url}:latest"
  package_type  = "Image"

  role = aws_iam_role.s3_to_rds_function_role.arn

  environment {
    variables = {
        DB_HOST = var.DB_HOST
        DB_PORT = var.DB_PORT
        DB_NAME = var.DB_NAME
        DB_USER = var.DB_USER
        DB_PASSWORD = var.DB_PASSWORD
    }
  }

}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_rds_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.gdtc-task-bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.gdtc-task-bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_rds_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
resource "aws_iam_role" "s3_to_rds_function_role" {
  name = "s3-to-rds"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Attach policy granting access to S3
resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  role       = aws_iam_role.s3_to_rds_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach policy granting access to RDS
resource "aws_iam_role_policy_attachment" "rds_access_policy_attachment" {
  role       = aws_iam_role.s3_to_rds_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.s3_to_rds_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}