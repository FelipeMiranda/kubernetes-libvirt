# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
BASE_BOX_NAME = "focal-server-cloudimg-amd64-vagrant"
BASE_BOX_URL = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-vagrant.box"

MASTER_HOSTNAME = "enki"
WORKER_NODE_01 = "enlil"
WORKER_NODE_02 = "utu"

INTNET_NAME = "privateSubnet"
BRIDGE_INTERFACE = "en1: Wi-Fi (AirPort)"

MASTER_INTNET_IP = "192.168.14.20"
MASTER_BRIDGE_01_IP = "192.168.15.20" # Node IP
MASTER_BRIDGE_02_IP = "192.168.15.30" # Used by Metal LB

WORKER_NODE_01_INTNET_IP = "192.168.14.21"
WORKER_NODE_01_BRIDGE_01_IP = "192.168.15.21" # Node IP
WORKER_NODE_01_BRIDGE_02_IP = "192.168.15.31" # Used by Metal LB

WORKER_NODE_02_INTNET_IP = "192.168.14.22"
WORKER_NODE_02_BRIDGE_01_IP = "192.168.15.22" # Node IP
WORKER_NODE_02_BRIDGE_01_IP = "192.168.15.32" # Used by Metal LB

Vagrant.configure("2") do |config|
    config.env.enable
    config.ssh.insert_key = false    
    # VM's
    config.vm.define :enki do |enki|
	    enki.vm.box = BASE_BOX_NAME
        enki.vm.box_url = BASE_BOX_URL
        enki.vm.hostname = MASTER_HOSTNAME
        enki.vm.network :private_network, virtualbox__intnet: INTNET_NAME,
            name: "eth4", # It´s not working
            ip: MASTER_INTNET_IP,
            netmask: "255.255.255.0"
        enki.vm.network :public_network, bridge: BRIDGE_INTERFACE,
            name: "eth5", # It´s not working
            ip: MASTER_BRIDGE_01_IP,
            netmask: "255.255.255.0"
        enki.vm.network :public_network, bridge: BRIDGE_INTERFACE,
            name: "eth6", # It´s not working
            ip: MASTER_BRIDGE_02_IP,
            netmask: "255.255.255.0"
        enki.vm.cloud_init do |cloud_init|
            cloud_init.content_type = "text/cloud-config"
            cloud_init.path = "./cloud-init/UserData.yaml"
        end
        enki.vm.provider :virtualbox do |v|
            v.memory = 2048
            v.cpus = 2
        end
    end
    config.vm.define :enlil do |enlil|
	enlil.vm.box = BASE_BOX_NAME
        enlil.vm.box_url = BASE_BOX_URL
        enlil.vm.hostname = WORKER_NODE_01
        enlil.vm.network :private_network, virtualbox__intnet: INTNET_NAME,
            name: "enp0s2",
            ip: WORKER_NODE_01_INTNET_IP,
            netmask: "255.255.255.0"
        enlil.vm.network :public_network, bridge: BRIDGE_INTERFACE,
            name: "enp0s3",
            ip: WORKER_NODE_01_BRIDGE_01_IP,
            netmask: "255.255.255.0"
        enlil.vm.network :public_network, bridge: BRIDGE_INTERFACE,  
            name: "enp0s4",
            ip: WORKER_NODE_01_BRIDGE_02_IP,
            netmask: "255.255.255.0"
        enlil.vm.cloud_init do |cloud_init|
            cloud_init.content_type = "text/cloud-config"
            cloud_init.path = "./cloud-init/UserData.yaml"
        end
        enlil.vm.provider :virtualbox do |v|
            v.memory = 2048
            v.cpus = 2
        end
    end
    config.vm.define :utu do |utu|
        utu.vm.box = BASE_BOX_NAME
        utu.vm.box_url = BASE_BOX_URL
        utu.vm.hostname = WORKER_NODE_02
        utu.vm.network :private_network, virtualbox__intnet: INTNET_NAME,
            name: "enp0s2",
            ip: WORKER_NODE_02_INTNET_IP,
            netmask: "255.255.255.0"
        utu.vm.network :public_network, bridge: BRIDGE_INTERFACE,
            name: "enp0s3",
            ip: WORKER_NODE_02_BRIDGE_01_IP,
            netmask: "255.255.255.0"
        utu.vm.network :public_network, bridge: BRIDGE_INTERFACE,
            name: "enp0s4",
            ip: WORKER_NODE_02_BRIDGE_01_IP,
            netmask: "255.255.255.0"
        utu.vm.cloud_init do |cloud_init|
            cloud_init.content_type = "text/cloud-config"
            cloud_init.path = "./cloud-init/UserData.yaml"
        end
        utu.vm.provider :virtualbox do |v|
            v.memory = 2048
            v.cpus = 2
        end
        utu.vm.provision "master-playbook", type: 'ansible' do |ansible|
            ansible.playbook = "provisioning/master-playbook.yaml"
            ansible.config_file = "ansible.cfg"
            ansible.inventory_path = "provisioning/hosts"
            ansible.limit = "all"
            ansible.extra_vars = {
               node_ip: MASTER_BRIDGE_01_IP,
            }
        end
        utu.vm.provision "worker-playbook", type: 'ansible' do |ansible|
            ansible.playbook = "provisioning/nodes-playbook.yaml"
            ansible.config_file = "ansible.cfg"
            ansible.inventory_path = "provisioning/hosts"
            ansible.limit = "all"
            ansible.extra_vars = {
                worker_01_node_ip: WORKER_NODE_01_BRIDGE_01_IP,
                worker_02_node_ip: WORKER_NODE_02_BRIDGE_01_IP,
            }
        end
        utu.vm.provision "deploy-charts", type: 'ansible' do |ansible|
            ansible.playbook = "provisioning/deploy-helm-charts-playbook.yaml"
            ansible.limit = "all"
            ansible.config_file = "ansible.cfg"
            ansible.inventory_path = "provisioning/hosts"
        end
    end 
end
