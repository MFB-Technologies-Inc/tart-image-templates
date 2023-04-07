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

variable "xcode_version" {
  type    = string
  default = "14.3"
}

variable "xcode_xip" {
  type    = string
  default = "" // local.remote_xcode_xip used when empty
}

variable "vm_base_name" {
  type    = string
  default = "" // local.default_vm_base_name used when empty
}

local "default_vm_base_name" {
  expression = "${var.macos_version}-base"
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
  default = 90
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
  vm_base_name = var.vm_base_name == "" ? local.default_vm_base_name : var.vm_base_name
  vm_name      = "${var.macos_version}-xcode:${var.xcode_version}"
  cpu_count    = var.cpu_count
  memory_gb    = var.memory_gb
  disk_size_gb = var.disk_size_gb
  headless     = true
  ssh_password = var.ssh_password
  ssh_username = var.ssh_username
  ssh_timeout  = var.ssh_timeout
}

local "wget_xcode_install" {
  expression = [
    "echo 'export PATH=/usr/local/bin/:$PATH' >> ~/.zprofile",
    "source ~/.zprofile",
    "wget --quiet https://github.com/RobotsAndPencils/xcodes/releases/latest/download/xcodes.zip",
    "unzip xcodes.zip",
    "rm xcodes.zip",
    "chmod +x xcodes",
    "sudo mkdir -p /usr/local/bin/",
    "sudo mv xcodes /usr/local/bin/xcodes",
    "xcodes version",
    "wget --quiet https://storage.googleapis.com/xcodes-cache/Xcode_${var.xcode_version}.xip",
    "xcodes install ${var.xcode_version} --experimental-unxip --path $PWD/Xcode_${var.xcode_version}.xip",
    "sudo rm -rf ~/.Trash/*",
    "xcodes select ${var.xcode_version}",
    "xcodebuild -runFirstLaunch",
  ]
}

local "local_xcode_install" {
  expression = [
    "echo 'export PATH=/usr/local/bin/:$PATH' >> ~/.zprofile",
    "source ~/.zprofile",
    "wget --quiet https://github.com/RobotsAndPencils/xcodes/releases/latest/download/xcodes.zip",
    "unzip xcodes.zip",
    "rm xcodes.zip",
    "chmod +x xcodes",
    "sudo mkdir -p /usr/local/bin/",
    "sudo mv xcodes /usr/local/bin/xcodes",
    "xcodes version",
    "xcodes install ${var.xcode_version} --experimental-unxip --path ${var.xcode_xip}",
    "sudo rm -rf ~/.Trash/*",
    "xcodes select ${var.xcode_version}",
    "xcodebuild -runFirstLaunch"
  ]
}

build {
  sources = ["source.tart-cli.tart"]

  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "brew --version",
      "brew update",
      "brew upgrade",
      "brew install curl wget unzip zip ca-certificates",
    ]
  }

  provisioner "shell" {
    inline = var.xcode_xip == "" ? local.wget_xcode_install : local.local_xcode_install
  }

  # inspired by https://github.com/actions/runner-images/blob/fb3b6fd69957772c1596848e2daaec69eabca1bb/images/macos/provision/configuration/configure-machine.sh#L33-L61
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      //"sudo security delete-certificate -Z FF6797793A3CD798DC5B2ABEF56F73EDC9F83A64 /Library/Keychains/System.keychain",
      "curl -o add-certificate.swift https://raw.githubusercontent.com/actions/runner-images/fb3b6fd69957772c1596848e2daaec69eabca1bb/images/macos/provision/configuration/add-certificate.swift",
      "swiftc add-certificate.swift",
      "curl -o AppleWWDRCAG3.cer https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer",
      "curl -o DeveloperIDG2CA.cer https://www.apple.com/certificateauthority/DeveloperIDG2CA.cer",
      "sudo ./add-certificate AppleWWDRCAG3.cer",
      "sudo ./add-certificate DeveloperIDG2CA.cer",
      "rm add-certificate* *.cer"
    ]
  }
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "brew doctor",
      "xcodebuild -version"
    ]
  }
}

local "remote_xcode_xip" {
  expression = "https://storage.googleapis.com/xcodes-cache/Xcode_${var.xcode_version}.xip"
}