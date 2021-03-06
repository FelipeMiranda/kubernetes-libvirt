terraform {
  required_providers {
    libvirt = {
      source = "multani/libvirt"
      version = "0.6.3-1+4"
    }
  }
}
provider "libvirt" {
  uri = "qemu:///system"
}

##
## Volumes
resource "libvirt_volume" "kubernetes_master_qcow2" {
  name = "kubernetes_master.qcow2"
  pool = "default"

  source = "/var/lib/libvirt/images/docker-server-ubuntu-20.04-server-cloudimg-amd64.qcow2"
  format = "qcow2"
}
resource "libvirt_volume" "kubernetes_worker1_qcow2" {
  name = "kubernetes_worker1.qcow2"
  pool = "default"

  source = "/var/lib/libvirt/images/docker-server-ubuntu-20.04-server-cloudimg-amd64.qcow2"
  format = "qcow2"
}
resource "libvirt_volume" "kubernetes_worker2_qcow2" {
  name = "kubernetes_worker2.qcow2"
  pool = "default"

  source = "/var/lib/libvirt/images/docker-server-ubuntu-20.04-server-cloudimg-amd64.qcow2"
  format = "qcow2"
}

##
## Define network as bridge
resource "libvirt_network" "bridge_network" {
  name = "bridge_network"
  mode = "bridge"
  bridge = "br0"
  autostart = true
}

##
## Machines User data templates
data "template_file" "kubernetes_master_user_data" {
  template = "${file("${path.module}/kubernetes_master_cloud_init.cfg")}"
}
data "template_file" "kubernetes_worker1_user_data" {
  template = "${file("${path.module}/kubernetes_worker1_cloud_init.cfg")}"
}
data "template_file" "kubernetes_worker2_user_data" {
  template = "${file("${path.module}/kubernetes_worker2_cloud_init.cfg")}"
}

##
## Machines Network Config templates
data "template_file" "kubernetes_master_network_config" {
  template = "${file("${path.module}/kubernetes_master_network_config.yml")}"
}
data "template_file" "kubernetes_worker1_network_config" {
  template = "${file("${path.module}/kubernetes_worker1_network_config.yml")}"
}
data "template_file" "kubernetes_worker2_network_config" {
  template = "${file("${path.module}/kubernetes_worker2_network_config.yml")}"
}

##
## Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "kubernetes_master_commoninit" {
  name = "kubernetes_master_commoninit.iso"
  user_data      = "${data.template_file.kubernetes_master_user_data.rendered}"
  network_config = "${data.template_file.kubernetes_master_network_config.rendered}"
}
resource "libvirt_cloudinit_disk" "kubernetes_worker1_commoninit" {
  name = "kubernetes_worker1_commoninit.iso"
  user_data      = "${data.template_file.kubernetes_worker1_user_data.rendered}"
  network_config = "${data.template_file.kubernetes_worker1_network_config.rendered}"
}
resource "libvirt_cloudinit_disk" "kubernetes_worker2_commoninit" {
  name = "kubernetes_worker2_commoninit.iso"
  user_data      = "${data.template_file.kubernetes_worker2_user_data.rendered}"
  network_config = "${data.template_file.kubernetes_worker2_network_config.rendered}"
}

##
## Define KVM domain for kubernetes master
resource "libvirt_domain" "kubernetes_master" {
  name   = "kubernetes_master"
  memory = "4096"
  vcpu   = 2
  autostart = true

  network_interface {
    network_name = "bridge_network"
  }

  disk {
    volume_id = "${libvirt_volume.kubernetes_master_qcow2.id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.kubernetes_master_commoninit.id}"

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

##
## Define KVM domain for kubernetes worker1
resource "libvirt_domain" "kubernetes_worker1" {
  name   = "kubernetes_worker1"
  memory = "4096"
  vcpu   = 2
  autostart = true

  network_interface {
    network_name = "bridge_network"
  }

  disk {
    volume_id = "${libvirt_volume.kubernetes_worker1_qcow2.id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.kubernetes_worker1_commoninit.id}"

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

##
## Define KVM domain for kubernetes worker2
resource "libvirt_domain" "kubernetes_worker2" {
  name   = "kubernetes_worker2"
  memory = "4096"
  vcpu   = 2
  autostart = true

  network_interface {
    network_name = "bridge_network"
  }

  disk {
    volume_id = "${libvirt_volume.kubernetes_worker2_qcow2.id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.kubernetes_worker2_commoninit.id}"

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}
# Output Server IP
output "ip_master" {
  value = "${libvirt_domain.kubernetes_master.network_interface.0}"
}
output "ip_worker1" {
  value = "${libvirt_domain.kubernetes_worker1.network_interface.0}"
}
output "ip_worker2" {
  value = "${libvirt_domain.kubernetes_worker2.network_interface.0}"
}
