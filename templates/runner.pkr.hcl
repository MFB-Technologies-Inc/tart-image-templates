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

variable "vm_base_name" {
  type    = string
  default = "" // local.default_vm_base_name used when empty
}

local "default_vm_base_name" {
  expression = "${var.macos_version}-xcode:${var.xcode_version}"
}

variable "gha_version" {
  type    = string
  default = "2.303.0"
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
  default = 91
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
  vm_name      = "${var.macos_version}-xcode:${var.xcode_version}-runner"
  cpu_count    = var.cpu_count
  memory_gb    = var.memory_gb
  disk_size_gb = var.disk_size_gb
  headless     = true
  ssh_password = var.ssh_password
  ssh_username = var.ssh_username
  ssh_timeout  = var.ssh_timeout
}

build {
  sources = ["source.tart-cli.tart"]

  provisioner "shell" {
    inline = [
      "cd $HOME",
      "rm -rf actions-runner",
      "mkdir actions-runner && cd actions-runner",
      "curl -O -L https://github.com/actions/runner/releases/download/v${var.gha_version}/actions-runner-osx-arm64-${var.gha_version}.tar.gz",
      "tar xzf ./actions-runner-osx-arm64-${var.gha_version}.tar.gz",
      "rm actions-runner-osx-arm64-${var.gha_version}.tar.gz",
    ]
  }
}
