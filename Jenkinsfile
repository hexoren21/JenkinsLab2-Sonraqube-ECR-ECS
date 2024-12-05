def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger',
]

pipeline {
    agent any
    stages {
        stage('SonarQube Analysis') {
            environment {
                scannerHome = tool 'sonar4.7'
                JAVA_HOME = "/usr/lib/jvm/java-1.11.0-openjdk-amd64"
                PATH = "${JAVA_HOME}/bin:${env.PATH}"
        }
        steps {
              withSonarQubeEnv('sonar-pro') {
                        sh '''
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=SQ-ECR-ECS\
                        -Dsonar.projectName=SQ-ECR-ECS \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=2087_kalay/ \
                        -Dsonar.language=web \
                        -Dsonar.sourceEncoding=UTF-8
                        '''
                }
            }
        }
        stage('Check Quality Gate') {
            steps {
                script {
                    echo 'Waiting for SonarQube to process the Quality Gate...'
                    sleep(time: 10, unit: 'SECONDS')
                    def qualityGate = waitForQualityGate()
                    if (qualityGate.status == 'ERROR' || qualityGate.status == 'FAILED') {
                        error "Pipeline failed: Quality Gate status is ${qualityGate.status}"
                    } else if (qualityGate.status == 'OK') {
                        echo 'Quality Gate passed successfully!'
                    } else {
                        echo "Quality Gate status: ${qualityGate.status}. Proceeding..."
                    }
                }
            }
        }
        stage('Build Docker Image') {     
            steps {
                script {
                    sh 'docker stop sq-ecr-ecs || true'
                    sh 'docker rm sq-ecr-ecs || true'
                    sh 'docker build -t sq-ecr-ecs .'
                }
            }
        }
        stage('Run Docker Container') {
            steps {         
                sh 'docker run -d -p 81:80 --name sq-ecr-ecs sq-ecr-ecs'
            }
        }
        stage('Test Application') {
            steps {
                script {
                    def status = sh(script: 'curl -o /dev/null -s -w "%{http_code}" http://localhost:81', returnStdout: true).trim()
                    if (status != '200') {
                        error "Application is not working as expected! HTTP Status: ${status}"
                    } else {
                        echo 'Application is running successfully!'
                    }
                }
            }
        }
    }
    post { 
        always {
            echo 'Slack Notifications.'
            slackSend channel: '#decopscicd',
                color: COLOR_MAP[currentBuild.currentResult],
                message: '*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}'
        }
    }
}