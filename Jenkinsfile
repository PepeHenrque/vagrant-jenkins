pipeline {
    agent any

    tools {
        nodejs 'node'
    }

    stages {
        stage('Instalar Dependências') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Teste') {
            steps {
                sh 'npm test -- --runInBand'
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