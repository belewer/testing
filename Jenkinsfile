String VERSION_BUILD

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
          containers:
          - name: node
            image: node:16-alpine
            command:
            - cat
            tty: true
          - name: helm
            image: alpine/helm
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

  tools {
    nodejs 'nodejs'
  }

  stages {

    stage('Install') {
      steps {

        echo '\033[35m############ STAGE: Install dependencies\033[0m'
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
        }
      }
    }  

    stage('Build') {
      steps {
        container('docker') {
          script {
            sh 'apk add jq'
            env.VERSION = sh(returnStdout: true, script:'jq -r .version package.json')
            VERSION_BUILD = env.VERSION
            sh 'docker build -t testing:\${VERSION} .'
          }
        }
      }
    }

    stage('Scan') {
      steps {
        container('docker') {
          sh "docker run -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image testing:${env.VERSION}"
        }
      }
    }  

    stage('Publish') {
      steps {
        container('docker') {
          withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
              sh "docker login -u $USER -p $PASS"
              sh 'docker tag testing:\${VERSION} jovilon/testing:\${VERSION}'
              sh "docker push jovilon/testing:${env.VERSION}"
          }
        }
      }
    }

    stage('Deploy') {
      steps {
        container('helm') {
          script {
            sh "helm upgrade --install testing chart/testing/ -f chart/testing/values.yaml -n apps --set image.tag=${VERSION_BUILD}"
          }
        }
      }
    }  



}
}