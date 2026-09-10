pipeline {
    agent any

    tools {
        nodejs 'node'
    }

    stages {
        stage('Instalar Dependências') {
            steps {
                bat 'npm ci'
            }
        }

        stage('Build') {
            steps {
                bat 'npm run build'
            }
        }

        stage('Teste') {
            steps {
                bat 'npm test -- --runInBand'
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