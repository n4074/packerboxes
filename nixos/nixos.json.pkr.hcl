# This file was autogenerate by the BETA 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# All generated input variables will be of string type as this how Packer JSON
# views them; you can later on change their type. Read the variables type
# constraints documentation
# https://www.packer.io/docs/from-1.5/variables#type-constraints for more info.
variable "esxi_hostport" {
  type    = string
  default = "22"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:3ebbf9cd9bdff0c7394eaef408c5c4f816c2f1d044b6e140c7531bbd17be1c47"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "https://channels.nixos.org/nixos-20.03/latest-nixos-minimal-x86_64-linux.iso"
}

variable "output_directory" {
  type    = string
  default = "build/"
}

variable "root_password" {
  type    = string
}

variable "name" {
  type    = string
  default = "nixos-base"
}

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors onto a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source
source "vmware-iso" "nixos-base" {
  boot_command      = ["<down><enter><wait45s>", "sudo su<enter><wait1s>", "passwd<enter><wait1s>", "${var.root_password}<enter><wait1s>", "${var.root_password}<enter><wait1s>", "systemctl start sshd<enter>"]
  boot_key_interval = "5ms"
  boot_wait         = "3s"
  cores             = 2
  disk_size         = 81920
  guest_os_type     = "other4xlinux-64"
  http_directory    = "${var.http_directory}"
  iso_checksum      = var.iso_checksum
  iso_url           = var.iso_url
  keep_registered   = true
  memory            = 8192
  #output_directory  = "${var.output_directory}/${var.vm_name}"
  shutdown_command  = "systemctl poweroff"
  skip_export       = true
  sound             = true
  ssh_password      = "${var.root_password}"
  ssh_username      = "root"
  ssh_wait_timeout  = "500s"
  usb               = true
  vm_name           = "${var.vm_name}"
  vmx_data = {
    firmware                                   = "efi"
    "gui.fitGuestUsingNativeDisplayResolution" = "TRUE"
    "gui.perVMFullscreenAutofitMode"           = "resize"
    "gui.perVMWindowAutofitMode"               = "resize"
    "mks.enable3d"                             = "TRUE"
  }
  vnc_disable_password = true
}

# a build block invokes sources and runs provisionning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  source "vmware-iso.nixos-base" {
    name = var.name
    output_directory = var.name
  }

  provisioner "shell" {
    scripts = ["partition.sh"]
  }
  provisioner "shell" {
    inline = ["nix-env -i git", "nixos-generate-config --root /mnt"]
  }
  provisioner "file" {
    destination = "/mnt/etc/nixos/configuration.nix"
    source      = "configuration.nix"
  }
  provisioner "shell" {
    inline = ["nixos-install --root /mnt --show-trace", "yes | ssh-keygen -t ed25519 -N \"\" -f /mnt/etc/ssh/ssh_host_ed25519_key"]
  }
  provisioner "file" {
    destination = "/mnt/etc/ssh/ca.pub"
    source      = "${var.ssh_ca_pub_key}"
  }
  provisioner "file" {
    destination = "./ssh_host_ed25519_key.pub"
    direction   = "download"
    source      = "/mnt/etc/ssh/ssh_host_ed25519_key.pub"
  }
  provisioner "shell-local" {
    inline = ["yes | ssh-keygen -h -Us ${var.ssh_ca_pub_key} -I nixos-base -n nixos-base -V +365d ssh_host_ed25519_key.pub"]
  }
  provisioner "file" {
    destination = "/mnt/etc/ssh/ssh_host_ed25519_key-cert.pub"
    generated   = true
    source      = "ssh_host_ed25519_key-cert.pub"
  }
  provisioner "shell" {
    inline = ["nixos-enter --root /mnt", "export HISTFILE=/dev/null", " echo root:${var.root_password} | chpasswd"]
  }
}

build {
  source "vmware-iso.nixos-base" {
    name = var.name
    output_directory = var.name
  }

  provisioner "shell" {
    scripts = ["partition.sh"]
  }
  provisioner "shell" {
    inline = ["nix-env -i git", "nixos-generate-config --root /mnt"]
  }
  provisioner "file" {
    destination = "/mnt/etc/nixos/configuration.nix"
    source      = "configuration.nix"
  }
  provisioner "shell" {
    inline = ["nixos-install --root /mnt --show-trace", "yes | ssh-keygen -t ed25519 -N \"\" -f /mnt/etc/ssh/ssh_host_ed25519_key"]
  }
  provisioner "file" {
    destination = "/mnt/etc/ssh/ca.pub"
    source      = "${var.ssh_ca_pub_key}"
  }
  provisioner "file" {
    destination = "./ssh_host_ed25519_key.pub"
    direction   = "download"
    source      = "/mnt/etc/ssh/ssh_host_ed25519_key.pub"
  }
  provisioner "shell-local" {
    inline = ["yes | ssh-keygen -h -Us ${var.ssh_ca_pub_key} -I nixos-base -n nixos-base -V +365d ssh_host_ed25519_key.pub"]
  }
  provisioner "file" {
    destination = "/mnt/etc/ssh/ssh_host_ed25519_key-cert.pub"
    generated   = true
    source      = "ssh_host_ed25519_key-cert.pub"
  }
  provisioner "shell" {
    inline = ["nixos-enter --root /mnt", "export HISTFILE=/dev/null", " echo root:${var.root_password} | chpasswd"]
  }
}
