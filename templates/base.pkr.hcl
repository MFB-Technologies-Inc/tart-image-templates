packer {
  required_plugins {
    tart = {
      version = ">= 0.5.4"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

variable "macos_version" {
  type    = string
  default = "13.3.1"
}

variable "cpu_count" {
  type    = number
  default = 4
}

variable "memory_gb" {
  type    = number
  default = 8
}

variable "disk_size_gb" {
  type    = number
  default = 40
}

variable "ssh_username" {
  type    = string
  default = "admin"
}

variable "ssh_password" {
  type    = string
  default = "admin"
}

variable "ssh_timeout" {
  type    = string
  default = "120s"
}

source "tart-cli" "tart" {
  vm_base_name = "${var.macos_version}-vanilla"
  vm_name      = "${var.macos_version}-base"
  cpu_count    = var.cpu_count
  memory_gb    = var.memory_gb
  disk_size_gb = var.disk_size_gb
  ssh_password = var.ssh_password
  ssh_username = var.ssh_username
  ssh_timeout  = var.ssh_timeout
}

build {
  sources = ["source.tart-cli.tart"]

  provisioner "shell" {
    inline = [
      "echo 'Disabling spotlight...'",
      "sudo mdutil -a -i off",
    ]
  }

  # setup DNS
  provisioner "shell" {
    inline = [
      "networksetup -setdnsservers Ethernet 8.8.8.8 8.8.4.4 1.1.1.1",
    ]
  }

  # Create a symlink for bash compatibility
  provisioner "shell" {
    inline = [
      "touch ~/.zprofile",
      "ln -s ~/.zprofile ~/.profile",
    ]
  }

  provisioner "shell" {
    inline = [
      "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"",
      "echo \"export LANG=en_US.UTF-8\" >> ~/.zprofile",
      "echo 'eval \"$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.zprofile",
      "echo \"export HOMEBREW_NO_AUTO_UPDATE=1\" >> ~/.zprofile",
      "echo \"export HOMEBREW_NO_INSTALL_CLEANUP=1\" >> ~/.zprofile",
      "source ~/.zprofile",
      "brew --version",
      "brew update"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo safaridriver --enable",
    ]
  }
}
