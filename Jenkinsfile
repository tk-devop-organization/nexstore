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
    agent {
        docker { image 'ruby:3.2.2' }  // Use the Ruby 3.2.2 Docker image
    }

    stages {
        stage('SCM Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Backend - Install Dependencies') {
            steps {
                script {
                    sh 'gem install bundler'  // Install bundler if not already installed
                    sh 'bundle install'       // Install project dependencies via bundler
                }
            }
        }

        stage('Backend - Run RSpec Tests') {
            steps {
                sh 'RAILS_ENV=test bundle exec rspec --format RspecJunitFormatter --out rspec_results.xml'
            }
            post {
                always {
                    // Archive RSpec test results and show them in Jenkins (JUnit format)
                    archiveArtifacts artifacts: 'rspec_results.xml', allowEmptyArchive: true
                    junit 'rspec_results.xml'
                }
            }
        }

        stage('Frontend - Install Dependencies') {
            steps {
                dir('frontend') {
                    sh 'npm install'  // Install Node.js dependencies for React app
                }
            }
        }

        stage('Frontend - Run ESLint') {
            steps {
                dir('frontend') {
                    sh 'npm run lint -- --format junit --output-file frontend/eslint_results.xml || true'
                }
            }
            post {
                always {
                    // Archive ESLint results and show them in Jenkins
                    archiveArtifacts artifacts: 'frontend/eslint_results.xml', allowEmptyArchive: true
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    // This will use the SonarQube Scanner from Global Tool Configuration
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
