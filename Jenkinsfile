pipeline {
    agent any

    stages {
        stage('Instalar Dependências') {
            steps {
                dir('app') {
                    sh 'npm ci'
                }
            }
        }

        stage('Build') {
            steps {
                dir('app') {
                    sh 'npm run build'
                }
            }
        }

        stage('Teste') {
            steps {
                dir('app') {
                    sh 'npm test'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executado com sucesso!'
        }

        failure {
            echo 'Pipeline falhou. Verifique os logs acima.'
        }
    }
}
