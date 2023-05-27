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
  stages {

    stage('Install') {
      steps {
        container('node') {
          sh 'npm install --production'
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
      steps {
        def scannerHome = tool 'SonarScanner 4.0';
        withSonarQubeEnv('sonar-minikube') { // If you have configured more than one global server connection, you can specify its name
        sh "${scannerHome}/bin/sonar-scanner"
      }
    }        

}
}