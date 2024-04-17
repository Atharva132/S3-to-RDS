# GDTC Task


## Workflow
Automated CI/CD Jenkins Pipeline to 
- Create docker image of python program that pushes data from s3 bucket to RDS instance.
- Push the Image to ECR.
- Run Terraform Scripts to create S3 Bucket, RDS DB instance, Lambda function using the Image, IAM role for Lambda function to access S3 Bucket, RDS and CloudWatch.
- When csv file is uploaded to S3 Bucket the Lambda function is triggered which starts transfer of data.

# Images

![Alt text](https://drive.google.com/file/d/1N-C7GrKltBbRH9mZ1WwGoluXLGRtYUn3/view?usp=drive_link "a title")
![Alt text](https://drive.google.com/file/d/1zxk-K24q02S2_TEIQ0VT7Pk3dGN-aOCe/view?usp=sharing "a title")