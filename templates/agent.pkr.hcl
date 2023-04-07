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

variable "agent_version" {
  type    = string
  default = "3.218.0"
}

variable "agent_name" {
  type    = string
  default = "pipeline-agent"
}

variable "azure_auth_pat" {
  type    = string
  default = ""
}

variable "azure_org_url" {
  type    = string
  default = ""
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
  default = 100
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
  vm_name      = "${var.macos_version}-xcode:${var.xcode_version}-agent:${var.agent_name}"
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
      "mkdir pipeline-agent && cd pipeline-agent",
      "curl -O -L https://vstsagentpackage.azureedge.net/agent/${var.agent_version}/vsts-agent-osx-arm64-${var.agent_version}.tar.gz",
      "xattr -c vsts-agent-osx-arm64-${var.agent_version}.tar.gz",
      "tar zxf ./vsts-agent-osx-arm64-${var.agent_version}.tar.gz",
      "rm vsts-agent-osx-arm64-${var.agent_version}.tar.gz",
      "./config.sh --unattended --url ${var.azure_org_url} --auth PAT --token ${var.azure_auth_pat} --acceptTeeEula --agent ${var.agent_name} --pool 'Mac Pool' --replace ${var.agent_name}",
      "./svc.sh install",
      "./svc.sh start"
    ]
  }
}
