#!/usr/bin/env bash
# ---------------------------------------------------------------
# Provisionamento da VM "jenkins"
# Instala: Java (dependência do Jenkins), Jenkins e Node.js
# ---------------------------------------------------------------
set -e

echo ">>> Atualizando pacotes..."
sudo apt-get update -y

echo ">>> Instalando dependências básicas..."
sudo apt-get install -y curl wget gnupg2 ca-certificates apt-transport-https software-properties-common lsb-release openssh-client

# ---------------------------------------------------------------
# Java (necessário para o Jenkins)
# ---------------------------------------------------------------
echo ">>> Instalando OpenJDK 17..."
sudo apt-get install -y openjdk-17-jdk

# ---------------------------------------------------------------
# Jenkins
# ---------------------------------------------------------------
echo ">>> Adicionando repositório e chave do Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
echo ">>> Instalando Jenkins..."
sudo apt-get install -y jenkins

echo ">>> Habilitando e iniciando o serviço Jenkins..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

# ---------------------------------------------------------------
# Node.js (necessário para builds/pipelines do app Node)
# ---------------------------------------------------------------
echo ">>> Instalando Node.js LTS (20.x)..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

echo ">>> Versões instaladas:"
java -version
node -v
npm -v
jenkins --version || true

# ---------------------------------------------------------------
# Extra: prepara chave SSH para o Jenkins poder conectar na VM "prod"
# (o par de chaves deve ser copiado manualmente ou via script auxiliar
#  depois do "vagrant up" -- ver README.md, seção "conexão SSH host -> prod")
# ---------------------------------------------------------------
sudo mkdir -p /var/lib/jenkins/.ssh
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh
sudo chmod 700 /var/lib/jenkins/.ssh

echo ">>> Provisionamento da VM Jenkins concluído com sucesso!"
echo ">>> Acesse http://192.168.56.10:8080 para configurar o Jenkins."
echo ">>> Senha inicial de administrador:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword || true
