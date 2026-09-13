pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['deploy', 'destroy'],
            description: 'Deploy or destroy application'
        )
    }

    environment {
        AWS_REGION = 'us-west-2'
        EKS_CLUSTER = 'eks-platform-dev'
        ECR_REPO = '590183658640.dkr.ecr.us-west-2.amazonaws.com/eks-flask-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        HELM_CHART = './helm/flask-app'
        
        SES_FROM = 'nithin.achary06@gmail.com'
        SES_TO = 'motog95666@94an.com'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                sh 'docker build -t $ECR_REPO:$IMAGE_TAG ./app'
            }
        }

        // stage('Trivy Scan') {
        //     when {
        //         expression { params.ACTION == 'deploy' }
        //     }
        //     steps {
        //         sh '''
        //             trivy image \
        //             --exit-code 1 \
        //             --severity HIGH,CRITICAL \
        //             $ECR_REPO:$IMAGE_TAG
        //         '''
        //     }
        // }

        stage('ECR Push') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login \
                    --username AWS \
                    --password-stdin \
                    590183658640.dkr.ecr.$AWS_REGION.amazonaws.com

                    docker push $ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Configure EKS') {
            steps {
                sh '''
                    aws eks update-kubeconfig \
                    --region $AWS_REGION \
                    --name $EKS_CLUSTER
                '''
            }
        }

        stage('Deploy DEV') {
            when {
                allOf {
                    expression { params.ACTION == 'deploy' }
                    expression {
                        env.BRANCH_NAME == 'feature' ||
                        env.BRANCH_NAME?.startsWith('feature/')
                    }
                }
            }
            steps {
                sh '''
                    helm upgrade --install flask-app-dev $HELM_CHART \
                    --namespace app \
                    --set image.repository=$ECR_REPO \
                    --set image.tag=$IMAGE_TAG
                '''
            }
        }

        stage('Destroy DEV') {
            when {
                allOf {
                    expression { params.ACTION == 'destroy' }
                    expression { env.BRANCH_NAME?.startsWith('feature/') }
                }
            }
            steps {
                sh '''
                    helm uninstall flask-app-dev \
                    --namespace app || true
                '''
            }
        }

        stage('Prod Approval') {
            when {
                allOf {
                    expression { params.ACTION == 'deploy' }
                    branch 'main'
                }
            }
            steps {
                input message: 'Deploy to PROD?', ok: 'Deploy'
            }
        }

        stage('Deploy PROD') {
            when {
                allOf {
                    expression { params.ACTION == 'deploy' }
                    branch 'main'
                }
            }
            steps {
                sh '''
                    helm upgrade --install flask-app-prod $HELM_CHART \
                    --namespace app \
                    --set image.repository=$ECR_REPO \
                    --set image.tag=$IMAGE_TAG
                '''
            }
        }

        stage('Destroy PROD Approval') {
            when {
                allOf {
                    expression { params.ACTION == 'destroy' }
                    branch 'main'
                }
            }
            steps {
                input message: 'Destroy PROD application?', ok: 'Destroy'
            }
        }

        stage('Destroy PROD') {
            when {
                allOf {
                    expression { params.ACTION == 'destroy' }
                    branch 'main'
                }
            }
            steps {
                sh '''
                    helm uninstall flask-app-prod \
                    --namespace app || true
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully. ACTION=${params.ACTION}"
        }

        failure {
            echo "Pipeline failed. ACTION=${params.ACTION}"

        sh '''
            aws ses send-email \
              --region $AWS_REGION \
              --from "$SES_FROM" \
              --destination "ToAddresses=$SES_TO" \
              --message "Subject={Data=Jenkins Pipeline Failed},Body={Text={Data=Pipeline $JOB_NAME build $BUILD_NUMBER failed. Branch: $BRANCH_NAME Action: $ACTION Build URL: $BUILD_URL}}"
        '''
        }
    }
}