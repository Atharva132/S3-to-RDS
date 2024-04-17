pipeline {
    agent any
    
    environment {
        TF_VAR_DB_PASSWORD = "${params.DB_PASSWORD}"
        DOCKER_TOKEN = "${params.DOCKER_TOKEN}"
        AWS_DEFAULT_REGION = "${params.AWS_DEFAULT_REGION}"
        AWS_ACCOUNT_ID = "${params.AWS_ACCOUNT_ID}"
        IMAGE_REPO_NAME = "gdtc-image"
        IMAGE_TAG = "latest"
        REPOSITORY_URI = "${params.AWS_ACCOUNT_ID}.dkr.ecr.${params.AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }
    
    stages{
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: '0dcb07a3-f793-4648-895b-7ed763f9b6ca', url: 'https://github.com/Atharva132/gdtc-task']])
            }
        }
        
        stage('Logging into AWS ECR') {
            steps {
                script {
                    withAWS(credentials: 'jenkins-aws', region: 'us-east-1'){
                        sh """aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"""
                    }
                }
            }
        }
        
        stage('Building image') {
            steps{
                script {
                    dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                }
            }
        }
        
        stage('Pushing to ECR') {
            steps{ 
                script {
                    sh """docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"""
                    sh """docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"""
                }
            }
        }
        
        stage('Terraform Init'){
            steps {
                dir('terraform-gdtc'){
                    withAWS(credentials: 'jenkins-aws', region: 'us-east-1'){
                        sh('terraform init')
                    }
                }
            }
        }
        
        stage('Terraform Plan'){
            steps{
                withAWS(credentials: 'jenkins-aws', region: 'us-east-1'){
                    dir('terraform-gdtc'){
                        sh('terraform plan')
                    }
                }
            }
        }
        
        stage('Terraform Action'){
            steps {
                withAWS(credentials: 'jenkins-aws', region: 'us-east-1'){
                    dir('terraform-gdtc'){
                        sh('terraform ${action} --auto-approve')
                    }
                }
            }
        }
    }
}