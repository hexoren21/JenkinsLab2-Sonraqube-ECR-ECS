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
                        -Dsonar.sources=2113_earth/ \
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
    }
}