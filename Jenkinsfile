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

        stage('Build (se existir)') {
            steps {
                dir('app') {
                    sh '''
                      if npm run | grep -q " build"; then
                        npm run build
                      else
                        echo "Sem script build, pulando..."
                      fi
                    '''
                }
            }
        }

        stage('Teste (se existir)') {
            steps {
                dir('app') {
                    sh '''
                      if npm run | grep -q " test"; then
                        npm test -- --runInBand || npm test
                      else
                        echo "Sem script test, pulando..."
                      fi
                    '''
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
