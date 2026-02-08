pipeline {
    agent any
    
    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '2'))
    }
    
    environment {
        APP_NAME    = "java-loginApp"
        REGISTRY    = "docker-io"
        IMAGE_TAG   = "${GIT_COMMIT}"
        KUBECONFIG  = "/etc/rancher/k3s/k3s.yaml"

    }

    stages {
        stage ('cleaning WS') {
            steps {
                cleanWs()
            }
        }
        stage('checkout code ') {
            steps {
                echo 'code is cloned from github'
                checkout scm
            }
        }
        stage('build & unit tests') {
            steps {
                echo 'mvn test done'
                sh  '''
                mvn clean test
                '''
            }
        }
        stage('Package Application') {
            steps {
                echo 'Application packaged'
                sh '''
                mvn package -Dskiptests
                '''
            }
        }
        stage('Archive Artifacts') {
            steps {
                echo 'Artifact archived'
                archiveArtifacts artifacts: 'target/*.war', fingerprint: true
            }
        }
        stage ('build docker image') {
            steps {
                echo 'building image'
                sh 'docker build -t shadow493/java-login:${BUILD_NUMBER} .'
            }
        }
         stage('Push to DockerHub') {
            steps {
                echo 'Pushing Image to Hub'
                withDockerRegistry(credentialsId: 'dock-cred', url: 'https://index.docker.io/v1/') {
                sh "docker login"    
                sh "docker push shadow493/java-login:${BUILD_NUMBER}"
                }
            }
         }
         stage('Deploy Application with k8s') {
             steps {
                 sh 'kubectl apply -f deployment.yml'
                 sh 'kubectl apply -f service.yml'
                 sh 'kubectl apply -f namespace.yml'
             }
         }
         stage('Cleanup') {
            steps {
                sh '''
                docker container prune -f
                docker image prune -f
                docker image prune -a
                '''
            }
        }
    } 
        post {
            success {
                echo 'Build successful WAR artifact is ready'
            }
           failure {
               echo "Build failed. Check logs and test reports."
                }
            }
        }
