# GDTC Task


## Workflow
Automated CI/CD Jenkins Pipeline to 
- Create docker image of python program that pushes data from s3 bucket to RDS instance.
- Push the Image to ECR.
- Run Terraform Scripts to create S3 Bucket, RDS DB instance, Lambda function using the Image, IAM role for Lambda function to access S3 Bucket, RDS and CloudWatch.
- When csv file is uploaded to S3 Bucket the Lambda function is triggered which starts transfer of data.