pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Docker Build & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DU', passwordVariable: 'DP')]) {
          // Secure login
          sh 'echo "$DP" | docker login -u "$DU" --password-stdin'

          // Build & push to your Docker Hub repo
          sh 'docker build -t dockerdavid007/glitch:latest .'
          sh 'docker push dockerdavid007/glitch:latest'
        }
      }
    }
  }
}
