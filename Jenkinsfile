pipeline {

    // options {
    //     ansiColor('xterm')
    // }

  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          securityContext:
            runAsUser: 0
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
            securityContext:
                runAsUser: 0            
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
                sh 'apt-get upgrade && apt-get update && curl -fsSL https://deb.nodesource.com/setup_16.x | bash -'
                sh "${scannerHome}/bin/sonar-scanner"
            }
        }
    }


    stage('Checkmarx') {
      steps {
        container('docker') {
          sh 'docker run -t -v ${WORKSPACE}:/path checkmarx/kics:latest scan -p /path -o "/path/"'
        }
      }
    }  



}
}