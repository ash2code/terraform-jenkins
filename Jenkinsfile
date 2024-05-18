pipeline {
    agent any 

    environment {
        AWS_ACCESS_KEY_ID = credentials("aws-cred")
        AWS_SECRET_ACCESS_KEY = credentials("aws-cred")
        TERRAFORM_DESTROY = "NO"
    }

    stages{
        stage("checkout-code") {
            step {
            git branch: 'main', url: 'https://github.com/ash2code/terraform-jenkins.git'
            }
        }
        stage("terraform init") {
            step {
                script {
                    sh "terraform init"
                }
            }
        }
        stage("terraform plan") {
            step {
                script {
                    sh "terraform plan"
                }
            }
        }
        stage("terraform-apply") {
            step {
                script {
                    sh "terraform apply --auto-approve"
                }
            }
        }
        stage("terraform-destroy") {
            step {
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
        