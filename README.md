# Projeto Vagrant + Jenkins

Ambiente com duas máquinas virtuais Ubuntu criadas pelo Vagrant. A primeira
executa o Jenkins e a segunda representa o servidor de produção da aplicação
Node.js.

| VM | Nome no VirtualBox | IP | Memória | CPU | Softwares |
|---|---|---|---:|---:|---|
| `jenkins` | `dupla-jenkins-host` | `192.168.56.10` | 1024 MB | 2 | Java 21, Jenkins e Node.js 20 |
| `prod` | `dupla-prod-app` | `192.168.56.20` | 1024 MB | 1 | Node.js 20 e OpenSSH Server |

## Estrutura

```text
.
|-- Vagrantfile
|-- Jenkinsfile
|-- app/
|   |-- index.js
|   |-- package.json
|   `-- package-lock.json
`-- vagrant/
    `-- scripts/
        |-- jenkins.sh
        `-- prod.sh
```

## Pré-requisitos

- Vagrant
- VirtualBox

## Subindo o ambiente

Na pasta do projeto, execute:

```powershell
vagrant up
```

Comandos úteis:

```powershell
vagrant status
vagrant ssh jenkins
vagrant ssh prod
vagrant halt
```

As máquinas também podem ser iniciadas separadamente:

```powershell
vagrant up jenkins
vagrant up prod
```

## Acessando o Jenkins

O Jenkins fica disponível em:

```text
http://192.168.56.10:8080
```

A senha inicial pode ser consultada com:

```powershell
vagrant ssh jenkins -c "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

## Preparando o acesso SSH ao servidor de produção

O deploy do Pipeline usa SSH e SCP. Portanto, o usuário `jenkins` precisa ter
uma chave autorizada na VM `prod`.

Gere a chave na VM Jenkins:

```powershell
vagrant ssh jenkins -c "sudo -u jenkins ssh-keygen -t rsa -b 4096 -f /var/lib/jenkins/.ssh/id_rsa -N ''"
```

Copie a chave pública para a VM de produção:

```powershell
$jenkinsPublicKey = (vagrant ssh jenkins -c "sudo cat /var/lib/jenkins/.ssh/id_rsa.pub").Trim()
vagrant ssh prod -c "echo '$jenkinsPublicKey' >> /home/vagrant/.ssh/authorized_keys && chmod 600 /home/vagrant/.ssh/authorized_keys"
```

Teste a conexão:

```powershell
vagrant ssh jenkins -c "sudo -u jenkins ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.56.20 'hostname && node -v'"
```

## Criando o Pipeline

No Jenkins, crie um trabalho do tipo **Pipeline** e configure:

- Definição: **Pipeline script from SCM**
- SCM: **Git**
- Repository URL: `https://github.com/PepeHenrque/vagrant-jenkins.git`
- Credentials: nenhuma, pois o repositório é público
- Branch Specifier: `*/main`
- Script Path: `Jenkinsfile`

Depois de salvar, clique em **Construir agora**.

O Pipeline executa as seguintes etapas:

1. Instala as dependências com `npm ci`.
2. Valida o código nos estágios de build e teste.
3. Copia a pasta `app` para `/home/vagrant/app-prod` na VM `prod`.
4. Instala as dependências e inicia a aplicação em segundo plano.

Quando a construção terminar com sucesso, acesse:

```text
http://192.168.56.20:3000
```

Para consultar o log da aplicação:

```powershell
vagrant ssh prod -c "cat /home/vagrant/app-prod/app.log"
```

## Teste manual da aplicação

Além do deploy do Pipeline, a pasta local `app/` é sincronizada com
`/home/vagrant/app` na VM `prod`. Para executar essa cópia manualmente:

```powershell
vagrant ssh prod
cd /home/vagrant/app
npm start
```

A cópia sincronizada em `/home/vagrant/app` é diferente do deploy automático,
que utiliza `/home/vagrant/app-prod`.

## Removendo o ambiente

Para apagar as duas máquinas virtuais criadas por este projeto:

```powershell
vagrant destroy -f
```

Os endereços `192.168.56.10` e `192.168.56.20` pertencem à rede privada do
VirtualBox. O box utilizado é o `ubuntu/jammy64`.
