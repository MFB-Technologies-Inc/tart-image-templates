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

variable "ipsw" {
  type    = string
  default = "" // local.remote_ipsw used when empty
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

# Doesn't seem to evaluate correctly
local "macos_major_version" {
  expression = substr(var.macos_version, 0, 2)
}

source "tart-cli" "tart" {
  # You can find macOS IPSW URLs on various websites like https://ipsw.me/
  # and https://www.theiphonewiki.com/wiki/Beta_Firmware/Mac/13.x
  from_ipsw    = var.ipsw == "" ? lookup(local.remote_ipsw, var.macos_version, "") : var.ipsw
  vm_name      = "${var.macos_version}-vanilla"
  cpu_count    = var.cpu_count
  memory_gb    = var.memory_gb
  disk_size_gb = var.disk_size_gb
  boot_command = lookup(local.boot_command, local.macos_major_version, [])
  ssh_password = var.ssh_password
  ssh_username = var.ssh_username
  ssh_timeout  = var.ssh_timeout

  // A (hopefully) temporary workaround for Virtualization.Framework's
  // installation process not fully finishing in a timely manner
  create_grace_time = "30s"
}

build {
  sources = ["source.tart-cli.tart"]

  provisioner "shell" {
    inline = lookup(local.provision, local.macos_major_version, [])
  }
}

local "boot_command" {
  expression = {
    "12" = local.boot_command_macos_12
    "13" = local.boot_command_macos_13
  }
}

local "boot_command_macos_12" {
  expression = [
    # hello, hola, bonjour, etc.
    "<wait60s><spacebar>",
    # Language
    "<wait30s><enter>",
    # Select Your Country and Region
    "<wait30s>united states<leftShiftOn><tab><leftShiftOff><spacebar>",
    # Written and Spoken Languages
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Accessibility
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Data & Privacy
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Migration Assistant
    "<wait10s><tab><tab><tab><spacebar>",
    # Sign In with Your Apple ID
    "<wait10s><leftShiftOn><tab><leftShiftOff><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Are you sure you want to skip signing in with an Apple ID?
    "<wait10s><tab><spacebar>",
    # Terms and Conditions
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # I have read and agree to the macOS Software License Agreement
    "<wait10s><tab><spacebar>",
    # Create a Computer Account
    "<wait10s>admin<tab><tab>admin<tab>admin<tab><tab><tab><spacebar>",
    # Enable Location Services
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Are you sure you don't want to use Location Services?
    "<wait10s><tab><spacebar>",
    # Select Your Time Zone
    "<wait10s><tab>UTC<enter><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Analytics
    "<wait10s><tab><spacebar><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Screen Time
    "<wait10s><tab><spacebar>",
    # Siri
    "<wait10s><tab><spacebar><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Choose Your Look
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Enable Voice Over
    "<wait10s><leftAltOn><f5><leftAltOff><wait5s>v",
    # Now that the installation is done, open "System Preferences"
    "<wait10s><leftAltOn><spacebar><leftAltOff>System Preferences<enter>",
    # Navigate to "Sharing"
    "<wait10s>sharing<enter>",
    # Enable Screen Sharing
    "<wait10s><tab><tab><tab><tab><spacebar>",
    # Enable Remote Login
    "<wait10s><down><down><down><down><spacebar><tab><tab><spacebar>",
    # Disable Voice Over
    "<leftAltOn><f5><leftAltOff>",
  ]
}

local "boot_command_macos_13" {
  expression = [
    # hello, hola, bonjour, etc.
    "<wait60s><spacebar>",
    # Language
    "<wait30s>english<enter>",
    # Select Your Country and Region
    "<wait30s>united states<leftShiftOn><tab><leftShiftOff><spacebar>",
    # Written and Spoken Languages
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Accessibility
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Data & Privacy
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Migration Assistant
    "<wait10s><tab><tab><tab><spacebar>",
    # Sign In with Your Apple ID
    "<wait10s><leftShiftOn><tab><leftShiftOff><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Are you sure you want to skip signing in with an Apple ID?
    "<wait10s><tab><spacebar>",
    # Terms and Conditions
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # I have read and agree to the macOS Software License Agreement
    "<wait10s><tab><spacebar>",
    # Create a Computer Account
    "<wait10s>admin<tab><tab>admin<tab>admin<tab><tab><tab><spacebar>",
    # Enable Location Services
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Are you sure you don't want to use Location Services?
    "<wait10s><tab><spacebar>",
    # Select Your Time Zone
    "<wait10s><tab>UTC<enter><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Analytics
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Screen Time
    "<wait10s><tab><spacebar>",
    # Siri
    "<wait10s><tab><spacebar><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Choose Your Look
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Enable Voice Over
    "<wait10s><leftAltOn><f5><leftAltOff><wait5s>v",
    # Now that the installation is done, open "System Settings"
    "<wait10s><leftAltOn><spacebar><leftAltOff>System Settings<enter>",
    # Navigate to "Sharing"
    "<wait10s><leftAltOn>f<leftAltOff>sharing<enter>",
    # Navigate to "Screen Sharing" and enable it
    "<wait10s><tab><down><spacebar>",
    # Navigate to "Remote Login" and enable it
    "<wait10s><tab><tab><tab><tab><tab><tab><spacebar>",
    # Open "Remote Login" details
    "<wait10s><tab><spacebar>",
    # Enable "Full Disk Access"
    "<wait10s><tab><spacebar>",
    # Click "Done"
    "<wait10s><leftShiftOn><tab><leftShiftOff><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Disable Voice Over
    "<leftAltOn><f5><leftAltOff>",
  ]
}

local "provision" {
  expression = {
    "12" = local.provision_macos_12
    "13" = local.provision_macos_13
  }
}

local "provision_macos_12" {
  expression = [
    // Enable passwordless sudo
    "echo admin | sudo -S sh -c \"echo 'admin ALL=(ALL) NOPASSWD: ALL' | EDITOR=tee visudo /etc/sudoers.d/admin-nopasswd\"",
    // Enable auto-login
    //
    // See https://github.com/xfreebird/kcpassword for details.
    "echo '00000000: 1ced 3f4a bcbc ba2c caca 4e82' | sudo xxd -r - /etc/kcpassword",
    "sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser admin",
    // Disable screensaver at login screen
    "sudo defaults write /Library/Preferences/com.apple.screensaver loginWindowIdleTime 0",
    // Prevent the VM from sleeping
    "sudo systemsetup -setdisplaysleep Off",
    "sudo systemsetup -setsleep Off",
    "sudo systemsetup -setcomputersleep Off",
    // Launch Safari to populate the defaults
    "/Applications/Safari.app/Contents/MacOS/Safari &",
    "sleep 3",
    "kill -9 %1",
    // Enable Safari's remote automation and "Develop" menu
    "sudo safaridriver --enable",
    "defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true",
    "defaults write com.apple.Safari IncludeDevelopMenu -bool true",
    // Disable screen lock
    //
    // Note that this only works if the user is logged-in,
    // i.e. not on login screen.
    "sysadminctl -screenLock off -password admin",
  ]
}

local "provision_macos_13" {
  expression = [
    // Enable passwordless sudo
    "echo admin | sudo -S sh -c \"mkdir -p /etc/sudoers.d/; echo 'admin ALL=(ALL) NOPASSWD: ALL' | EDITOR=tee visudo /etc/sudoers.d/admin-nopasswd\"",
    // Enable auto-login
    //
    // See https://github.com/xfreebird/kcpassword for details.
    "echo '00000000: 1ced 3f4a bcbc ba2c caca 4e82' | sudo xxd -r - /etc/kcpassword",
    "sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser admin",
    // Disable screensaver at login screen
    "sudo defaults write /Library/Preferences/com.apple.screensaver loginWindowIdleTime 0",
    // Prevent the VM from sleeping
    "sudo systemsetup -setdisplaysleep Off",
    "sudo systemsetup -setsleep Off",
    "sudo systemsetup -setcomputersleep Off",
    // Launch Safari to populate the defaults
    "/Applications/Safari.app/Contents/MacOS/Safari &",
    "sleep 30",
    "kill -9 %1",
    // Enable Safari's remote automation and "Develop" menu
    "sudo safaridriver --enable",
    "defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true",
    "defaults write com.apple.Safari IncludeDevelopMenu -bool true",
    // Disable screen lock
    //
    // Note that this only works if the user is logged-in,
    // i.e. not on login screen.
    "sysadminctl -screenLock off -password admin",
  ]
}

local "remote_ipsw" {
  expression = {
    "12.4"   = local.ipsw_12_4
    "12.5"   = local.ipsw_12_5
    "12.5.1" = local.ipsw_12_5_1
    "12.6"   = local.ipsw_12_6
    "13.0"   = local.ipsw_13_0
    "13.0.1" = local.ipsw_13_0_1
    "13.2"   = local.ipsw_13_2
    "13.2.1" = local.ipsw_13_2_1
    "13.3"   = local.ipsw_13_3
    "13.3.1" = local.ipsw_13_3_1
  }
}

local "ipsw_12_4" {
  expression = "https://updates.cdn-apple.com/2022SpringFCS/fullrestores/012-06874/9CECE956-D945-45E2-93E9-4FFDC81BB49A/UniversalMac_12.4_21F79_Restore.ipsw"
}

local "ipsw_12_5" {
  expression = "https://updates.cdn-apple.com/2022SummerFCS/fullrestores/012-42731/BD9917E0-262C-41C5-A69F-AC316A534A39/UniversalMac_12.5_21G72_Restore.ipsw"
}

local "ipsw_12_5_1" {
  expression = "https://updates.cdn-apple.com/2022SummerFCS/fullrestores/012-51674/A7019DDB-3355-470F-A355-4162A187AB6C/UniversalMac_12.5.1_21G83_Restore.ipsw"
}

local "ipsw_12_6" {
  expression = "https://updates.cdn-apple.com/2022FallFCS/fullrestores/012-40537/0EC7C669-13E9-49FB-BD64-9EECC1D174B2/UniversalMac_12.6_21G115_Restore.ipsw"
}

local "ipsw_13_0" {
  expression = "https://updates.cdn-apple.com/2022FallFCS/fullrestores/012-92188/2C38BCD1-2BFF-4A10-B358-94E8E28BE805/UniversalMac_13.0_22A380_Restore.ipsw"
}

local "ipsw_13_0_1" {
  expression = "https://updates.cdn-apple.com/2022FallFCS/fullrestores/012-93802/A7270B0F-05F8-43D1-A9AD-40EF5699E82C/UniversalMac_13.0.1_22A400_Restore.ipsw"
}

local "ipsw_13_2" {
  expression = "https://updates.cdn-apple.com/2022FallFCS/fullrestores/012-60270/0A7F49BA-FC31-4AD9-8E45-49B1FB9128A6/UniversalMac_13.1_22C65_Restore.ipsw"
}

local "ipsw_13_2_1" {
  expression = "https://updates.cdn-apple.com/2023WinterFCS/fullrestores/032-48346/EFF99C1E-C408-4E7A-A448-12E1468AF06C/UniversalMac_13.2.1_22D68_Restore.ipsw"
}

local "ipsw_13_3" {
  expression = "https://updates.cdn-apple.com/2023WinterSeed/fullrestores/002-75537/8250FA0E-0962-46D6-8A90-57A390B9FFD7/UniversalMac_13.3_22E252_Restore.ipsw"
}

local "ipsw_13_3_1" {
  expression = "https://updates.cdn-apple.com/2023WinterFCS/fullrestores/032-66602/418BC37A-FCD9-400A-B4FA-022A19576CD4/UniversalMac_13.3.1_22E261_Restore.ipsw"
}