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
    agent any  // This will run the pipeline on any available agent

    environment {
        // Define tools and environment variables if needed
        SONARQUBE_SCANNER_HOME = tool name: 'SonarScanner', type: 'ToolLocation'
    }

    stages {
        stage('SCM Checkout') {
            steps {
                // Checkout code from GitHub repository
                checkout scm
            }
        }

        stage('Backend - Install Dependencies') {
            steps {
                script {
                    // Install Ruby and Bundler dependencies for Rails
                    sh 'gem install bundler'
                    sh 'bundle install'
                }
            }
        }

        stage('Backend - Run RSpec Tests') {
            steps {
                // Run RSpec tests and output results to XML
                sh 'RAILS_ENV=test bundle exec rspec --format RspecJunitFormatter --out rspec_results.xml'
            }
            post {
                always {
                    // Archive RSpec test results and show in Jenkins (JUnit format)
                    archiveArtifacts artifacts: 'rspec_results.xml', allowEmptyArchive: true
                    junit 'rspec_results.xml'  // Jenkins will process the RSpec XML results
                }
            }
        }

        stage('Frontend - Install Dependencies') {
            steps {
                script {
                    // Install Node.js dependencies for React app
                    dir('frontend') {
                        sh 'npm install'
                    }
                }
            }
        }

        stage('Frontend - Run ESLint') {
            steps {
                // Run ESLint on the frontend directory and output to XML
                dir('frontend') {
                    sh 'npm run lint || true' // Continue even if linting fails
                }
            }
            post {
                always {
                    // Archive ESLint results (if any)
                    archiveArtifacts artifacts: 'frontend/eslint_results.xml', allowEmptyArchive: true
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    // Run SonarQube analysis on the codebase
                    withSonarQubeEnv('SonarQube') {
                        sh "${SONARQUBE_SCANNER_HOME}/bin/sonar-scanner"
                    }
                }
            }
        }
    }

    post {
        always {
            // Cleanup workspace after the build
            cleanWs()
        }
    }
}
