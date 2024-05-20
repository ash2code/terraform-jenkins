pipeline {
    agent any 

    environment {
        AWS_ACCESS_KEY_ID = credentials("aws-cred")
        AWS_SECRET_ACCESS_KEY = credentials("aws-cred")
        TERRAFORM_DESTROY = "NO"  // Change this to "YES" to trigger destroy
    }

    stages {
        stage("checkout-code") {
            steps {
                git branch: 'main', url: 'https://github.com/ash2code/terraform-jenkins.git'
            }
        }
        stage("terraform init") {
            steps {
                script {
                    sh "terraform init -input=false -force-copy"
                }
            }
        }
        stage("terraform plan") {
            steps {
                script {
                    sh "terraform plan -input=false"
                }
            }
        }
        stage("terraform apply") {
            when {
                expression { return env.TERRAFORM_DESTROY != 'YES' }
            }
            steps {
                script {
                    sh "terraform apply --auto-approve -input=false"
                }
            }
        }
        stage("terraform destroy") {
            when {
                expression { return env.TERRAFORM_DESTROY == 'YES' }
            }
            steps {
                script {
                    sh "terraform destroy -input=false --auto-approve"
                }
            }
        }
    }
}
