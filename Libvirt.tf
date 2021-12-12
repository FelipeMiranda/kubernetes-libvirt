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


resource "libvirt_volume" "kubernetes_master_qcow2" {
  name = "kubernetes_master.qcow2"
  pool = "default"

  source = "/var/lib/libvirt/images/docker-server-ubuntu-20.04-server-cloudimg-amd64.qcow2"
  format = "qcow2"
}

# Define network as bridge
resource "libvirt_network" "bridge_network" {
  name = "bridge_network"
  mode = "bridge"
  bridge = "br0"
  autostart = true
}
data "template_file" "kubernetes_master_user_data" {
  template = "${file("${path.module}/kubernetes_master_cloud_init.cfg")}"
}
data "template_file" "kubernetes_master_network_config" {
  template = "${file("${path.module}/kubernetes_master_network_config.yml")}"
}
# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "kubernetes_master_commoninit" {
  name = "kubernetes_master_commoninit.iso"
  user_data      = "${data.template_file.kubernetes_master_user_data.rendered}"
  network_config = "${data.template_file.kubernetes_master_network_config.rendered}"
}

# Define KVM domain to create
resource "libvirt_domain" "kubernetes_master" {
  name   = "kubernetes_master"
  memory = "4096"
  vcpu   = 2

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

# Output Server IP
output "ip" {
  value = "${libvirt_domain.kubernetes_master.network_interface.0}"
}

