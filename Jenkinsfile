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

    environment {
        // Define Ruby-related environment variables
        RVM_HOME = '/usr/local/rvm'
        PATH = "/usr/local/rvm/bin:${RVM_HOME}/rubies/ruby-3.2.2/bin:${env.PATH}" // Add Ruby and Bundler to PATH
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
                    // Ensure RVM is sourced before running gem or bundle commands
                    sh '''
                        apt-get update && apt-get install -y libpq-dev
                        . /usr/local/rvm/scripts/rvm
                        gem install bundler
                        bundle install
                    '''
                }
            }
        }

        stage('Backend - Run RSpec Tests') {
            steps {
                script {
                    // Run RSpec tests
                    sh 'RAILS_ENV=test bundle exec rspec --format RspecJunitFormatter --out rspec_results.xml'
                }
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
