# Kubernetes 1.21 deployment with no Docker
## Easy deploy with Vagrant, cloud-init, ansible and Virtualbox
## Install required tools

1. Virtualbox
2. Vagrant
3. Ansible

> **tested with Vagrant 2.2.16, ansible 2.10.8, virtualbox v6.1.22 on a MacOS but it should work on all systems**

This code will get you a 3 Vbox machines setup, each node with 1vcpu and 2GB of memory RAM with kubernetes 1.21 running with Containerd as the container engine, so no docker-shim ;)

The method of ingress, we choosed to install Metal LB and Ingress Nginx Controller, so we could have Loadbalance support on a Bare Metal installation.

Vagrant assume you have your first NIC as a virtualbox NAT to work properly, this causes every machine to have the same IP 10.0.2.15

As I wanted that the Kubernetes Cluster to be reachable by my local network I did setup 3 others NIC interfaces

Interface | VBox Type 
:---: | :---:
enp0s8 | Internal
enp0s9 | Bridge
enp0s10 | Bridge

> The internal network is not being used for now, just for convinience

> We have 2 NIC´s as bridge because Metal LB require a pool of IP´s that is not being used by the Kubernetes Cluster

### Ansible Playbooks

There´s 3 playbooks, that are only executed on the 3rd node, because of a Vagrant limitation on a multi-machine cenario.

1. master-playbook.yaml
2. nodes-playbooks.yaml
3. deploy-helm-charts-playbook.yaml
