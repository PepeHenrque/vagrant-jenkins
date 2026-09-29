pipeline {
    agent any

    environment {
        DEPLOY_HOST = '192.168.56.20'
        DEPLOY_USER = 'vagrant'
        DEPLOY_PATH = '/home/vagrant/app'
    }

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
                    sh 'npm test -- --runInBand'
                }
            }
        }

        stage('Deploy com SCP') {
            steps {
                sshagent(['deploy-key']) {
                    sh '''
                        set -e

                        echo "Testando conexão com a VM de produção..."
                        ssh -o StrictHostKeyChecking=no \
                            ${DEPLOY_USER}@${DEPLOY_HOST} \
                            "hostname"

                        echo "Criando diretório da aplicação..."
                        ssh -o StrictHostKeyChecking=no \
                            ${DEPLOY_USER}@${DEPLOY_HOST} \
                            "mkdir -p ${DEPLOY_PATH}"

                        echo "Copiando arquivos com SCP..."
                        scp -o StrictHostKeyChecking=no -r app/* \
                            ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}/

                        echo "Instalando dependências na produção..."
                        ssh -o StrictHostKeyChecking=no \
                            ${DEPLOY_USER}@${DEPLOY_HOST} \
                            "cd ${DEPLOY_PATH} && npm ci"

                        echo "Deploy concluído com sucesso!"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline concluída com sucesso, incluindo o deploy via SCP!'
        }

        failure {
            echo 'Pipeline falhou. Verifique os logs acima.'
        }
    }
}
