pipeline {
  agent any
  stages {
    stage('Docker Build & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DU', passwordVariable: 'DP')]) {
          // Login to Docker Hub
          sh 'docker login -u "$DU" -p "$DP"'

          // Build Docker image from Dockerfile in repo
          sh 'docker build -t <dockerhub-username>/learngit:latest .'

          // Push the image to Docker Hub
          sh 'docker push <dockerhub-username>/learngit:latest'
        }
      }
    }
  }
}