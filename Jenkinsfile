pipeline {
    agent {
        kubernetes {
        yaml '''
            apiVersion: v1
            kind: Pod
            spec:
            containers:
            - name: node
                image: node:16-alpine
                command:
                - cat
                tty: true
            - name: docker
                image: docker:latest
                command:
                - cat
                tty: true
                volumeMounts:
                - mountPath: /var/run/docker.sock
                name: docker-sock
            volumes:
            - name: docker-sock
                hostPath:
                path: /var/run/docker.sock    
            '''
        }
    }
    options {
        ansiColor('xterm')
    }    
    stages {

        stage('Install') {
        steps {
            container('node') {
            sh 'npm install'
            }
        }
        }  

        stage('Lint') {
        steps {
            container('node') {
            sh 'npm run lint'
            }
        }
        } 

        stage('Test') {
        steps {
            container('node') {
            sh 'npm run test'
            }
        }
        }     

        stage('Sonar') {
            steps{
                script {
                    scannerHome = tool 'sonar-scanner-minikube'
                }
                withSonarQubeEnv('sonar-minikube') {
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }


        stage('Checkmarx') {
        steps {
            container('docker') {
            sh 'docker run -t -v ${WORKSPACE}:/path checkmarx/kics:latest scan -p /path -o "/path/"'
            sh 'cat .scannerwork/report-task.txt'
            }
        }
        }  



    }
}