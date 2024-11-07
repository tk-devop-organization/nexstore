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
    agent any  // Use the Jenkins container itself

    stages {
        stage('SCM Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Backend - Install Dependencies') {
            steps {
                script {
                    // Ensure bundler is installed
                    sh 'gem install bundler'

                    // Install Ruby project dependencies
                    sh 'bundle install'
                }
            }
        }

        stage('Backend - Run RSpec Tests') {
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
            steps {
                dir('frontend') {
                    // Install frontend dependencies using Yarn (if Yarn is not yet installed)
                    sh 'npm install'  // This works with your installed Node.js version
                }
            }
        }

        stage('Frontend - Run ESLint') {
            steps {
                dir('frontend') {
                    // Run ESLint on the frontend code
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
                    // Configure SonarScanner for SonarQube analysis
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

