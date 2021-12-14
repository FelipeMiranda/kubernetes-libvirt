# Kubernetes 1.23 deployment with no Docker
## Easy deploy with Terraform, cloud-init, ansible and KVM
## Install required tools

1. KVM
2. Terraform
3. Ansible

KVM is virtualization module that is loaded inside the Linux kernel and then linux kernel start working as a KVM hypervisor. KVM stands for Kernel based Virtual Machine. Before start installing KVM on any Linux System we have to make sure that our system’s processor supports hardware virtualization extensions like Intel VT or AMD-V.

Following this guide you will have by the end a Kubeneters Cluster 1.23 with 1 master and 2 nodes, this is the fastet way to have a up and running K8S for your lab environment with Metal-LB, ingress-nginx installed with Helm Chart.

To provision all that you'll use Terraform and Ansible.

## Lab details
### k8s-master
* OS : OpenSUSE Leap 15.3
* Hostname : k8s-master
* IP address : 192.168.2.60
* Metal-LB : 192.168.2.50
* RAM : 4 GB
* CPU = 2
* Disk = 40 GB Free Space ( /var/lib/libvirtd)
### k8s-worker1
* OS : OpenSUSE Leap 15.3
* Hostname : k8s-worker1
* IP address : 192.168.2.61
* Metal-LB : 192.168.2.51
* RAM : 4 GB
* CPU = 2
* Disk = 40 GB Free Space ( /var/lib/libvirtd)
### k8s-worker2
* OS : OpenSUSE Leap 15.3
* Hostname : k8s-worker1
* IP address : 192.168.2.62
* Metal-LB : 192.168.2.52
* RAM : 4 GB
* CPU = 2
* Disk = 40 GB Free Space ( /var/lib/libvirtd)

## Requiriments
#### OpenSUSE 15.3 with KVM
1. Verify Whether Your System’s Processor Support Hardware Virtualization
```
$ sudo egrep -c '(vmx|svm)' /proc/cpuinfo
2
```
If output of below command is equal to 1 or more than 1 then we can say hardware virtualization is enabled else reboot your system, go to bios settings and enable the hardware virtualization by enabling the Intel VT or AMD virtualization

2. Install KVM and its dependencies using Zypper command
```
$ sudo zypper -n install patterns-openSUSE-kvm_server patterns-server-kvm_tools
```

3. Start and enable libvirtd service
```
$ sudo systemctl enable libvirtd
Created symlink /etc/systemd/system/multi-user.target.wants/libvirtd.service → /usr/lib/systemd/system/libvirtd.service.
Created symlink /etc/systemd/system/sockets.target.wants/virtlockd.socket → /usr/lib/systemd/system/virtlockd.socket.
Created symlink /etc/systemd/system/sockets.target.wants/virtlogd.socket → /usr/lib/systemd/system/virtlogd.socket.
```
```
$ sudo systemctl restart libvirtd
```
Note: If KVM module is not loaded after package installation then run below command to load it,
* For Intel based systems
```
$ sudo modprobe kvm-intel
```
* For AMD based systems
```
$ sudo modprobe kvm-amd
```

4. Create Bridge and add Interface to it
Let’s create a bride with name Br0 but before make sure bridge-utils package is installed, in case it is not installed then use the below zypper command to install it,
```
$ sudo zypper install bridge-utils
````
Now Start the Yast2 tool,

**Yast2** –> **Network Settings** –> click on Add option
![](https://github.com/FelipeMiranda/kubernetes-libvirt/blob/main/docs/images/Add-Bridge-SUSE-KVM.jpg?raw=true)

In the next window select the Device type as “Bridge” and Configuration Name as “br0”
![](docs/image/Device-Type-Bridge-Name-OpenSUSE-KVM.jpg)

click on Next,

In the Next Window, choose Statically assigned IP Option, Specify the IP address for Bridge, netmask and Hostname, i am assigning the same IP address that were assigned to my LAN Card eth0
![](docs/image/Br0-IP-address-SUSE-KVM.jpg)

Now Select the “Bridged Devices” Option and then select LAN Card that you want to associate with br0, in my case it was eth0
![](docs/image/Select-Interface-Bride-SUSE-KVM.jpg)

Click on Next to finish the configuration
![](docs/image/Save-Bridge-SUSE-KVM.jpg)

click OK to write device configuration

To verify whether bridge has been created successfully or not, type the below command from the terminal,
```
$ ip a s br0
3: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
link/ether 00:0c:29:63:d5:ea brd ff:ff:ff:ff:ff:ff
inet 192.168.0.107/24 brd 192.168.0.255 scope global br0
valid_lft forever preferred_lft forever
inet6 fe80::20c:29ff:fe63:d5ea/64 scope link
valid_lft forever preferred_lft forever
```

### Ansible Playbooks

There´s 3 playbooks, that are only executed on the 3rd node, because of a Vagrant limitation on a multi-machine cenario.

1. master-playbook.yaml
2. nodes-playbooks.yaml
3. deploy-helm-charts-playbook.yaml
