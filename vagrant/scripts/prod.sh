#!/usr/bin/env bash
# ---------------------------------------------------------------
# Provisionamento da VM "prod"
# Instala: Node.js (ambiente de execução do app)
# ---------------------------------------------------------------
set -e

echo ">>> Atualizando pacotes..."
sudo apt-get update -y

echo ">>> Instalando dependências básicas..."
sudo apt-get install -y curl wget gnupg2 ca-certificates openssh-server

# ---------------------------------------------------------------
# Node.js
# ---------------------------------------------------------------
echo ">>> Instalando Node.js LTS (20.x)..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

echo ">>> Versões instaladas:"
node -v
npm -v

# ---------------------------------------------------------------
# Garante que o serviço SSH esteja ativo para receber deploys
# vindos do host Jenkins (extra opcional).
# ---------------------------------------------------------------
sudo systemctl enable ssh
sudo systemctl start ssh

# ---------------------------------------------------------------
# (Opcional) Instala as dependências do app já sincronizado via
# synced_folder, deixando pronto para "npm start".
# ---------------------------------------------------------------
if [ -f /home/vagrant/app/package.json ]; then
  echo ">>> Instalando dependências do app..."
  cd /home/vagrant/app
  sudo -u vagrant npm install
fi

echo ">>> Provisionamento da VM Prod concluído com sucesso!"
echo ">>> Para rodar o app: vagrant ssh prod -c 'cd app && npm start'"
