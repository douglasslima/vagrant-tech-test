# -*- mode: ruby -*-
# vi: set ft=ruby :
# Using Yaml file to load personal settings
require 'yaml'
require 'fileutils'

settings = YAML.load_file 'settings/config.yaml'  # Edit settings/config.yaml values before vagrant up
timestamp = Time.now.strftime("%d%m%Y_%H%M")

# Private and public ssh keys
host_private_key = File.expand_path(File.join(Dir.home, '.ssh/id_rsa'))
host_public_key = File.expand_path(File.join(Dir.home, '.ssh/id_rsa.pub'))

# Create .ssh Folder and generate ssh key pair if not exist
ssh_path = File.expand_path(File.join(Dir.home, '.ssh/'))
if !File.directory?(ssh_path)
    puts "Path " + ssh_path + " not exists and will be created."
    FileUtils.mkdir_p(ssh_path)
    puts `ssh-keygen -t rsa -b 4096 -C #{settings['git_email']} -f #{ssh_path}/id_rsa -q -N ""`
end

Vagrant.configure("2") do |config|
    # Box Base Image
    config.vm.box = settings['vm_distro_version']
    # Box Hostname
    config.vm.hostname = settings['vm_hostname']
    # VirtualBox configurations - Change values in settings/config.yaml 
    config.vm.provider "virtualbox" do |v|
      v.name = settings['vm_name'] + " ( " + settings['git_username'] + " )" + " #{timestamp}"
      v.memory = settings['vm_memory']    
      v.cpus = settings['vm_cpu_count']   
    end

    # Install Required Plugins:
    settings['vagrant_plugins'].each do |plugin|
        unless Vagrant.has_plugin?("#{plugin['name']}")
          puts "Plugin: #{plugin['name']} will be installed!"
          system("vagrant plugin install #{plugin['name']} --plugin-version #{plugin['version']}")
          exit system('vagrant', *ARGV)
        end
    end

    # VB Guest Additions configuration:
    if Vagrant.has_plugin?('vagrant-vbguest')
      config.vbguest.auto_reboot = true
      config.vbguest.auto_update = false
    end

    # Setup Timezone
    if Vagrant.has_plugin?("vagrant-timezone")
      config.timezone.value = settings['timezone'] 
    end

    ## System Setup

    # Setup the git config --global vars
    config.vm.provision "shell", inline: "git config --global user.name #{settings['git_username']}", run: "once", privileged: false
    config.vm.provision "shell", inline: "git config --global user.email #{settings['git_email']}", run: "once", privileged: false
    config.vm.provision "shell", inline: "git config --global core.autocrlf false", run: "once", privileged: false
    config.vm.provision "shell", inline: "git config --global core.eol lf", run: "once", privileged: false
    config.vm.provision "shell", inline: "git config --list", run: "once", privileged: false

    # Copying ssh keys
    config.vm.provision "file", source: host_private_key, destination: "/home/vagrant/tmp/"
    config.vm.provision "file", source: host_public_key, destination: "/home/vagrant/tmp/"
    config.vm.provision "shell", inline: "sudo mv ~/tmp/id_rsa* ~/.ssh/", run: "once", privileged: false
    config.vm.provision "shell", inline: "sudo chmod 400 ~/.ssh/id_rsa* ", run: "once", privileged: false

    # Sync the root folder with the box
    config.vm.synced_folder ".", "/home/vagrant/documents", :mount_options => ["dmode=777", "fmode=777"]

    # Folder for cloning github projects and expose it to an IDE
    config.vm.synced_folder './projects', '/home/vagrant/projects', create: true

   # Vagrant system setup scripts
    if (settings['install_apps'])
      settings['install_apps'].each do |app|
        if ( app['enable'] == true && app['name'] == 'docker')
            config.vm.provision :docker
            config.vm.provision :docker_compose
        elsif( app['enable'] == true && app['name'] != 'docker' )
            config.vm.provision :shell, path: "scripts/#{app['name']}.sh", name: app['name'], privileged: false
        end
      end
    end

    # Private Network IP for External Access
    config.vm.network "private_network", ip: "192.168.50.11", hostname: true

    # Map Host Ports Into the Vagrant Box:
    if (settings['vagrant_extra_ports'])
      settings['vagrant_extra_ports'].each do |xport|
        config.vm.network :forwarded_port, guest: xport['guest_port'], host: xport['host_port'], auto_correct: true
      end
    end

  end
