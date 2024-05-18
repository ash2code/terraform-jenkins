pipeline {
    agent any 

    environment {
        AWS_ACCESS_KEY_ID = credentials("aws-cred")
        AWS_SECRET_ACCESS_KEY = credentials("aws-cred")
        TERRAFORM_DESTROY = "NO"
    }

    stages{
        stage("checkout-code") {
            steps {
            git branch: 'main', url: 'https://github.com/ash2code/terraform-jenkins.git'
            }
        }
        stage("terraform init") {
            steps {
                script {
                    sh "terraform init"
                }
            }
        }
        stage("terraform plan") {
            steps {
                script {
                    sh "terraform plan"
                }
            }
        }
        stage("terraform-apply") {
            steps {
                script {
                    sh "terraform apply --auto-approve"
                }
            }
        }
        stage("terraform-destroy") {
            steps {
                script {
                    if (env.TERRAFORM_DESTROY == 'yes') {
                        sh "terraform destroy --auto-approve"
                    }
                    else {
                        echo "terraform is not destroyed"
                    }
                }
            }
        }
    }
}
        