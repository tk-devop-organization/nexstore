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


// pipeline {
//     agent any

//     stages {
//         stage('SCM Checkout') {
//             agent {
//                 dockerContainer { image 'ruby:3.2.2' }  // Use the Ruby 3.2.2 Docker image for this stage
//             }
//             steps {
//                 checkout scm
//             }
//         }

//         stage('Backend - Install Dependencies') {
//             agent {
//                 dockerContainer { image 'ruby:3.2.2' }
//             }
//             steps {
//                 script {
//                     sh 'gem install bundler'  // Install bundler if not already installed
//                     sh 'bundle install'       // Install project dependencies via bundler
//                 }
//             }
//         }

//         stage('Backend - Run RSpec Tests') {
//             agent {
//                 dockerContainer { image 'ruby:3.2.2' }
//             }
//             steps {
//                 sh 'RAILS_ENV=test bundle exec rspec --format RspecJunitFormatter --out rspec_results.xml'
//             }
//             post {
//                 always {
//                     archiveArtifacts artifacts: 'rspec_results.xml', allowEmptyArchive: true
//                     junit 'rspec_results.xml'
//                 }
//             }
//         }

//         stage('Frontend - Install Dependencies') {
//             agent {
//                 dockerContainer { image 'node:16' }  // Use Node image for frontend
//             }
//             steps {
//                 dir('frontend') {
//                     sh 'npm install'  // Install Node.js dependencies for React app
//                 }
//             }
//         }

//         stage('Frontend - Run ESLint') {
//             agent {
//                 dockerContainer { image 'node:16' }  // Use Node image for frontend
//             }
//             steps {
//                 dir('frontend') {
//                     sh 'npm run lint -- --format junit --output-file frontend/eslint_results.xml || true'
//                 }
//             }
//             post {
//                 always {
//                     archiveArtifacts artifacts: 'frontend/eslint_results.xml', allowEmptyArchive: true
//                 }
//             }
//         }

//         stage('SonarQube Analysis') {
//             steps {
//                 script {
//                     def scannerHome = tool 'SonarScanner'  // Name must match SonarQube Scanner configured in Jenkins
//                     withSonarQubeEnv('SonarQube') {  // This should match your SonarQube server name
//                         sh "${scannerHome}/bin/sonar-scanner"
//                     }
//                 }
//             }
//         }
//     }

//     post {
//         always {
//             cleanWs()  // Clean up workspace after the build
//         }
//     }
// }




pipeline {
    agent any
    
    options {
        // Create Docker volumes for dependency caching
        dockerVolumeCreate('jenkins_gems')
        dockerVolumeCreate('jenkins_node_modules')
        // Add timeout for the whole pipeline
        timeout(time: 1, unit: 'HOURS')
    }

    environment {
        DOCKER_BUILDKIT = '1'
        COMPOSE_DOCKER_CLI_BUILD = '1'
        RAILS_ENV = 'test'
    }

    stages {
        stage('SCM Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Backend') {
            agent {
                docker { 
                    image 'ruby:3.2.2'
                    args '-v jenkins_gems:/usr/local/bundle'
                    reuseNode true
                }
            }
            options {
                timeout(time: 20, unit: 'MINUTES')
            }
            steps {
                script {
                    try {
                        sh '''
                            gem install bundler
                            bundle config set --local path "vendor/bundle"
                            bundle install --jobs=4 --retry=3
                            bundle exec rspec --format RspecJunitFormatter --out rspec_results.xml
                        '''
                    } catch (Exception e) {
                        echo "Backend stage failed: ${e.message}"
                        throw e
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'rspec_results.xml', allowEmptyArchive: true
                    junit 'rspec_results.xml'
                }
                failure {
                    echo 'Backend tests failed!'
                }
            }
        }

        stage('Frontend') {
            agent {
                docker { 
                    image 'node:16'
                    args '-v jenkins_node_modules:/app/frontend/node_modules'
                    reuseNode true
                }
            }
            options {
                timeout(time: 15, unit: 'MINUTES')
            }
            steps {
                dir('frontend') {
                    script {
                        try {
                            sh '''
                                npm ci
                                npm run lint -- --format junit --output-file eslint_results.xml || true
                            '''
                        } catch (Exception e) {
                            echo "Frontend stage failed: ${e.message}"
                            throw e
                        }
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'frontend/eslint_results.xml', allowEmptyArchive: true
                }
                failure {
                    echo 'Frontend tests failed!'
                }
            }
        }

        stage('SonarQube Analysis') {
            options {
                timeout(time: 10, unit: 'MINUTES')
            }
            steps {
                script {
                    try {
                        def scannerHome = tool 'SonarScanner'
                        withSonarQubeEnv('SonarQube') {
                            sh "${scannerHome}/bin/sonar-scanner"
                        }
                    } catch (Exception e) {
                        echo "SonarQube analysis failed: ${e.message}"
                        throw e
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        unstable {
            echo 'Pipeline is unstable!'
        }
    }
}