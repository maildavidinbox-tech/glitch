/* pipeline {
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
} */
// pipeline {
//   agent any

//   environment {
//     // --- Docker Hub (already working in your Lab 7) ---
//     DOCKER_IMAGE = 'dockerdavid007/glitch:latest'

//     // --- AWS / CodeDeploy (Lab 8) ---
//     AWS_DEFAULT_REGION = 'us-east-2'                  // <-- change if needed
//     S3_BUCKET          = 'david-codedeploy-artifacts'   // e.g., david-cicd-artifacts-123
//     CD_APP             = 'MyWebApp' // e.g., demo-cicd-app
//     CD_DG              = 'MyWebApp-DeploymentGroup'  // e.g., demo-cicd-dg
//   }

//   stages {
//     stage('Checkout') {
//       steps { checkout scm }
//     }

//     stage('Docker Build & Push') {
//       steps {
//         withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DU', passwordVariable: 'DP')]) {
//           sh 'echo "$DP" | docker login -u "$DU" --password-stdin'
//           sh 'docker build -t $DOCKER_IMAGE .'
//           sh 'docker push $DOCKER_IMAGE'
//         }
//       }
//     }

//     // ===== Lab 8 starts here =====

//     stage('Package & Upload to S3') {
//       steps {
//         // Ensure zip is available (Ubuntu agents). Remove if already installed.
//         sh 'which zip || (sudo apt-get update -y && sudo apt-get install -y zip)'

//         script {
//           // Build a unique key: artifacts/app-<build>-<shortsha>.zip
//           def sha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
//           env.BUILD_KEY = "artifacts/app-${env.BUILD_NUMBER}-${sha}.zip"
//         }

//         // Create deployable bundle including appspec.yml and scripts/
//         sh 'rm -f app.zip && zip -r app.zip * -x "*.git*"'

//         // Upload to S3 (requires AWS auth: instance role or aws configure/creds binding)
//         sh 'aws s3 cp app.zip s3://$S3_BUCKET/$BUILD_KEY'
//         echo "Uploaded: s3://$S3_BUCKET/$BUILD_KEY"
//       }
//     }

//     stage('Deploy via CodeDeploy') {
//       steps {
//         script {
//           // Create deployment pointing to the exact S3 key we just uploaded
//           def createCmd = "aws deploy create-deployment " +
//                           "--application-name '${env.CD_APP}' " +
//                           "--deployment-group-name '${env.CD_DG}' " +
//                           "--deployment-config-name CodeDeployDefault.OneAtATime " +
//                           "--file-exists-behavior OVERWRITE " +
//                           "--s3-location bucket='${env.S3_BUCKET}',bundleType=zip,key='${env.BUILD_KEY}'"

//           def out = sh(script: createCmd + " --output json", returnStdout: true).trim()
//           echo "create-deployment output: ${out}"

//           // Extract deploymentId (without jq)
//           def depId = sh(
//             script: "echo '${out.replace(\"'\",\"'\\\\''\")}' | sed -n 's/.*\\\"deploymentId\\\": \\\"\\([^\\\"]*\\)\\\".*/\\1/p'",
//             returnStdout: true
//           ).trim()
//           if (!depId) { error 'Failed to parse deploymentId' }
//           env.DEPLOYMENT_ID = depId
//           echo "DeploymentId: ${env.DEPLOYMENT_ID}"

//           // Block until CodeDeploy reports success (fails build if deployment fails)
//           sh "aws deploy wait deployment-successful --deployment-id ${env.DEPLOYMENT_ID}"
//         }
//       }
//     }
//   }

//   post {
//     success {
//       echo "✅ Build, push, package, and deploy completed."
//     }
//     failure {
//       echo "❌ Something failed. Check console output and CodeDeploy deployment logs."
//     }
//   }
// }
pipeline {
  agent any
  environment {
    AWS_DEFAULT_REGION = 'us-east-2'
    S3_BUCKET          = 'david-codedeploy-artifacts'
    CD_APP             = 'MyWebApp'
    CD_DG              = 'MyWebApp-DeploymentGroup'
    // Make sure Jenkins sees aws even if PATH is weird
    PATH = "/usr/local/bin:/usr/bin:/bin:/usr/local/aws-cli/v2/current/bin:${env.PATH}"
  }
  stages {
    stage('Prereqs') {
      steps {
        sh '''
          set -e
          echo "PATH=$PATH"
          which aws || { echo "ERROR: AWS CLI missing from PATH"; exit 127; }
          aws --version
          aws sts get-caller-identity >/dev/null
        '''
      }
    }

    stage('Checkout') { steps { checkout scm } }

    stage('Package & Upload') {
      steps {
        sh '''
          zip -r app.zip . -x "*.git*" "app.zip"
          aws s3 cp app.zip s3://$S3_BUCKET/app.zip --region $AWS_DEFAULT_REGION
        '''
      }
    }

    stage('Deploy') {
      steps {
        sh '''
          aws deploy create-deployment \
            --application-name $CD_APP \
            --deployment-group-name $CD_DG \
            --s3-location bucket=$S3_BUCKET,bundleType=zip,key=app.zip \
            --region $AWS_DEFAULT_REGION
        '''
      }
    }
  }
}
