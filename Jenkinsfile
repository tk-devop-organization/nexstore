// node {
//   stage('SCM') {
//     checkout scm
//   }
//   stage('SonarQube Analysis') {
//     def scannerHome = tool 'SonarScanner';
//     withSonarQubeEnv() {
//       sh "${scannerHome}/bin/sonar-scanner"
//     }
//   }
// }


pipeline {
    agent any

    stages {
        stage('SCM Checkout') {
            agent {
                dockerContainer { image 'ruby:3.2.2' }  // Use the Ruby 3.2.2 Docker image for this stage
            }
            steps {
                checkout scm
            }
        }

        stage('Backend - Install Dependencies') {
            agent {
                dockerContainer { image 'ruby:3.2.2' }
            }
            steps {
                script {
                    sh 'gem install bundler'  // Install bundler if not already installed
                    sh 'bundle install'       // Install project dependencies via bundler
                }
            }
        }

        stage('Backend - Run RSpec Tests') {
            agent {
                dockerContainer { image 'ruby:3.2.2' }
            }
            steps {
                sh 'RAILS_ENV=test bundle exec rspec --format RspecJunitFormatter --out rspec_results.xml'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'rspec_results.xml', allowEmptyArchive: true
                    junit 'rspec_results.xml'
                }
            }
        }

        stage('Frontend - Install Dependencies') {
            agent {
                dockerContainer { image 'node:16' }  // Use Node image for frontend
            }
            steps {
                dir('frontend') {
                    sh 'npm install'  // Install Node.js dependencies for React app
                }
            }
        }

        stage('Frontend - Run ESLint') {
            agent {
                dockerContainer { image 'node:16' }  // Use Node image for frontend
            }
            steps {
                dir('frontend') {
                    sh 'npm run lint -- --format junit --output-file frontend/eslint_results.xml || true'
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'frontend/eslint_results.xml', allowEmptyArchive: true
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'  // Name must match SonarQube Scanner configured in Jenkins
                    withSonarQubeEnv('SonarQube') {  // This should match your SonarQube server name
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()  // Clean up workspace after the build
        }
    }
}