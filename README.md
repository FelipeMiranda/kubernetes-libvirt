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

### Ansible Playbooks

There´s 3 playbooks, that are only executed on the 3rd node, because of a Vagrant limitation on a multi-machine cenario.

1. master-playbook.yaml
2. nodes-playbooks.yaml
3. deploy-helm-charts-playbook.yaml
