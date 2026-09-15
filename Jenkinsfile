pipeline {
    agent any
    stages {
        stage('Instalar Dependências') {
            steps {
                dir('app') {
                    sh 'npm install'
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
                    sh 'npm test -- --runInBand'
                }
            }
        }
    }
}
