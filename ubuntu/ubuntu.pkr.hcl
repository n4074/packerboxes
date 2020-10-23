variable "esxi_hostport" {
  type    = string
  default = "22"
}
    
variable "iso_checksum" {
  type    = string
  default = "sha256:443511f6bf12402c12503733059269a2e10dec602916c0a75263e5d990f6bb93"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/20.04/ubuntu-20.04.1-live-server-amd64.iso"
}

variable "output_directory" {
  type    = string
  default = "build/"
}

variable "password" {
  type    = string
  default = "ubuntu"
  sensitive = true
}

variable "username" {
  type = string
  default = "user"
}

variable "vm_name" {
  type    = string
  default = "ubuntu-base"
}

variable "http_dir" {
  type = string
  default = "./http_dir"
}

variable "ssh_ca_pub_key" {
  type = string
}

variable "ssh_ca_key" {
  type = string
}

locals { 
  timestamp = regex_replace(timestamp(), "[- TZ:]", "") 
  output_dir = "${var.output_directory}/${var.vm_name}"
  initial_password = "gaul-minutes-somewhat-umbrage-downtown-huh" # needs to match in user-
}

source "vmware-iso" "ubuntu-base" {
  boot_command      = [
    "<enter><enter><f6><esc><wait> ",
    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "<enter>"
    ]
  boot_key_interval = "5ms"
  boot_wait         = "3s"
  cores             = 2
  disk_size         = 81920
  guest_os_type     = "other4xlinux-64"
  http_directory    = var.http_dir
  iso_checksum      = var.iso_checksum
  iso_url           = var.iso_url
  keep_registered   = true
  memory            = 8192
  output_directory  = local.output_dir
  shutdown_command  = "systemctl poweroff"
  skip_export       = true
  sound             = true
  ssh_username      = var.username
  ssh_password      = local.initial_password
  ssh_wait_timeout  = "20m"
  ssh_handshake_attempts = 100
  usb               = true
  vm_name           = "${var.vm_name}"
  vmx_data = {
##    firmware                                   = "efi"
    "gui.fitGuestUsingNativeDisplayResolution" = "TRUE"
    "gui.perVMFullscreenAutofitMode"           = "resize"
    "gui.perVMWindowAutofitMode"               = "resize"
    "mks.enable3d"                             = "TRUE"
  }
}

build {
  sources = ["source.vmware-iso.ubuntu-base"]

  provisioner "shell" {
    inline = ["yes | ssh-keygen -t ed25519 -N \"\" -f /tmp/ssh_host_ed25519_key"]
  }

  provisioner "file" {
    source      = "/tmp/ssh_host_ed25519_key.pub"
    direction   = "download"
    destination = "./ssh_host_ed25519_key.pub"
  }
  
  provisioner "shell-local" {
    inline = ["yes | ssh-keygen -h -Us ${var.ssh_ca_key} -I ubuntu-base -n ubuntu-base -V +365d ssh_host_ed25519_key.pub"]
  }

  provisioner "file" {
    destination = "/tmp/ssh_host_ed25519_key-cert.pub"
    generated   = true
    source      = "ssh_host_ed25519_key-cert.pub"
  }

  provisioner "file" {
    destination = "/tmp/ca.pub"
    source      = var.ssh_ca_pub_key
  }

  provisioner "shell" {
    execute_command = "echo '${local.initial_password}' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "bash -c 'mv /tmp/{ca.pub,ssh_host_ed25519_*} /etc/ssh/'",
      "echo 'TrustedUserCAKeys /etc/ssh/ca.pub' >> /etc/ssh/sshd_config",
      "echo 'HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub' >> /etc/ssh/sshd_config",
      " echo ${var.username}:${var.password} | chpasswd"
    ]
  }
}
