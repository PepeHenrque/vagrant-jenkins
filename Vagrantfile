# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Configurações comuns às duas VMs
  config.vm.box = "ubuntu/jammy64"

  # ---------------------------------------------------------------
  # VM 1 - HOST JENKINS
  # ---------------------------------------------------------------
  config.vm.define "jenkins" do |jenkins|
    jenkins.vm.hostname = "jenkins"
    jenkins.vm.network "private_network", ip: "192.168.56.10"

    jenkins.vm.provider "virtualbox" do |vb|
      vb.name   = "jenkins-host"
      vb.memory = 1024
      vb.cpus   = 2
    end

    # Provisionamento via Shell
    jenkins.vm.provision "shell", path: "vagrant/scripts/jenkins.sh"

    jenkins.vm.post_up_message = <<-MSG
      VM Jenkins pronta!
      Acesse com: vagrant ssh jenkins
      Jenkins disponível em: http://192.168.56.10:8080
    MSG
  end

  # ---------------------------------------------------------------
  # VM 2 - AMBIENTE DE PRODUÇÃO (PROD)
  # ---------------------------------------------------------------
  config.vm.define "prod" do |prod|
    prod.vm.hostname = "prod"
    prod.vm.network "private_network", ip: "192.168.56.20"

    prod.vm.provider "virtualbox" do |vb|
      vb.name   = "prod-app"
      vb.memory = 1024
      vb.cpus   = 1
    end

    # (Opcional) Sincroniza a pasta app/ do host para dentro da VM prod,
    # permitindo testar a aplicação sem precisar copiar manualmente.
    prod.vm.synced_folder "app/", "/home/vagrant/app"

    # Provisionamento via Shell
    prod.vm.provision "shell", path: "vagrant/scripts/prod.sh"

    prod.vm.post_up_message = <<-MSG
      VM Prod pronta!
      Acesse com: vagrant ssh prod
      App (se iniciado) disponível em: http://192.168.56.20:3000
    MSG
  end

end
