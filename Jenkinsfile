pipeline {
    agent any

    environment {
        PROD = 'vagrant@192.168.56.20'
        SSH_OPTS = '-o StrictHostKeyChecking=accept-new'
    }

    stages {
        stage('Instalar Dependências') {
            steps { dir('app') { sh 'npm ci' } }
        }
        stage('Build') {
            steps { dir('app') { sh 'npm run build' } }
        }
        stage('Teste') {
            steps { dir('app') { sh 'npm test' } }
        }
        stage('Deploy') {
            steps {
                sh '''
                    ssh $SSH_OPTS $PROD "rm -rf /home/vagrant/app-prod"
                    scp $SSH_OPTS -r app $PROD:/home/vagrant/app-prod
                    ssh $SSH_OPTS $PROD "cd /home/vagrant/app-prod && npm ci && (pkill -f '^node index.js$' || true) && sleep 1 && (setsid nohup node index.js > app.log 2>&1 < /dev/null &)"
                '''
            }
        }
    }

    post {
        success { echo 'Deploy feito! App em http://192.168.56.20:3000' }
        failure { echo 'Pipeline falhou. O deploy não foi feito.' }
    }
}
