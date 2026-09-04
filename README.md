# Projeto Vagrant + Jenkins

Ambiente com duas VMs provisionadas via **Vagrant**, usando um único `Vagrantfile`
e `config.vm.define` para diferenciar cada máquina.

| VM        | Hostname  | IP              | Memória | CPU | Softwares            |
|-----------|-----------|-----------------|---------|-----|-----------------------|
| jenkins   | jenkins   | 192.168.56.10   | 1024 MB | 2   | Java 17, Jenkins, Node.js 20 |
| prod      | prod      | 192.168.56.20   | 1024 MB | 1   | Node.js 20, OpenSSH server  |

## Estrutura do repositório

```
.
├── Vagrantfile
├── app/
│   ├── index.js          # app Node.js de exemplo
│   └── package.json
└── vagrant/
    └── scripts/
        ├── jenkins.sh    # provisionamento da VM jenkins
        └── prod.sh       # provisionamento da VM prod
```

## Pré-requisitos

- [Vagrant](https://www.vagrantup.com/downloads)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (provider padrão usado neste Vagrantfile)

## Como usar

Subir as duas VMs de uma vez:

```bash
vagrant up
```

Subir apenas uma VM específica:

```bash
vagrant up jenkins
vagrant up prod
```

Acessar cada máquina:

```bash
vagrant ssh jenkins
vagrant ssh prod
```

Verificar status:

```bash
vagrant status
```

Destruir o ambiente:

```bash
vagrant destroy -f
```

## VM Jenkins

- Instala Java 17 (dependência do Jenkins), Jenkins e Node.js 20 via `vagrant/scripts/jenkins.sh`.
- Interface web disponível em: **http://192.168.56.10:8080**
- A senha inicial de administrador é exibida ao final do provisionamento
  (`vagrant up jenkins`), ou pode ser obtida depois com:

```bash
vagrant ssh jenkins -c "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

## VM Prod

- Instala Node.js 20 e o servidor OpenSSH via `vagrant/scripts/prod.sh`.
- A pasta `app/` do repositório é sincronizada automaticamente para
  `/home/vagrant/app` dentro da VM (via `prod.vm.synced_folder`), e o
  script de provisionamento já roda `npm install` se encontrar um
  `package.json`.

Para testar o app dentro do ambiente de produção:

```bash
vagrant ssh prod
cd app
npm start
```

Em outro terminal (na sua máquina host), teste o acesso:

```bash
curl http://192.168.56.20:3000
```

## Extra (opcional): conexão SSH entre o host Jenkins e a VM prod

Isso simula o Jenkins fazendo deploy/comandos remotos na VM de produção.

1. Gere um par de chaves SSH dentro da VM Jenkins, usando o usuário `jenkins`:

```bash
vagrant ssh jenkins
sudo -u jenkins ssh-keygen -t rsa -b 4096 -f /var/lib/jenkins/.ssh/id_rsa -N ""
sudo cat /var/lib/jenkins/.ssh/id_rsa.pub
```

2. Copie a chave pública exibida e adicione-a aos hosts autorizados da VM `prod`:

```bash
exit                     # sai da VM jenkins
vagrant ssh prod
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "<COLE_A_CHAVE_PUBLICA_AQUI>" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

3. Teste a conexão a partir da VM Jenkins:

```bash
exit                     # sai da VM prod
vagrant ssh jenkins
sudo -u jenkins ssh vagrant@192.168.56.20 "hostname && node -v"
```

Se a conexão funcionar sem pedir senha, o Jenkins já está apto a executar
jobs de deploy (via plugin **Publish Over SSH**, **SSH Agent** ou steps
`sh "ssh vagrant@192.168.56.20 ..."` em um `Jenkinsfile`) diretamente na
VM de produção.

## Observações

- Os IPs usados (`192.168.56.10` e `192.168.56.20`) são endereços de rede
  privada (`private_network`) do VirtualBox — ajuste-os no `Vagrantfile`
  caso conflitem com sua rede local.
- O box utilizado é o `ubuntu/jammy64` (Ubuntu Server 22.04 LTS), conforme
  requisito do projeto.
