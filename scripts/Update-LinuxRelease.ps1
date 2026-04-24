[CmdletBinding()]
param (
  [Parameter()]
  [switch]
  $Post,
  [Parameter()]
  [switch]
  $Force
)

if (!$IsLinux) {
  throw [System.NotImplementedException]::new()
}

$IsUbuntu = $PSVersionTable.OS.StartsWith('Ubuntu ')
$IsFedora = $PSVersionTable.OS.StartsWith('Fedora ')
$IsWSL = [bool]$env:WSL_DISTRO_NAME

switch ($true) {
  ($IsWSL -and !$Force) {
    Write-Warning 'please update wsl kernel first, then use -Force'
    wsl.exe -l -v
    wsl.exe --shutdown
    wsl.exe --update
    break
  }
  $Post {
    Get-Content /etc/os-release
    Write-Debug 'running post upgrade commands'
    if ($IsUbuntu) {
      systemctl --failed
      sudo apt install --fix-broken
      sudo apt update
      sudo apt dist-upgrade -y
    }
    elseif ($IsFedora) {
      sudo dnf system-upgrade clean
      sudo dnf distro-sync
    }
    break
  }
  default {
    if ($IsUbuntu) {
      Write-Debug 'installing tools and patches'
      sudo apt update
      sudo apt install -y update-manager
      sudo apt dist-upgrade -y
      sudo apt autoremove -y --purge
      sudo apt autoclean
      Write-Debug 'doing release upgrade'
      sudo do-release-upgrade
    }
    elseif ($IsFedora) {
      Write-Debug 'installing tools'
      sudo dnf upgrade --refresh
      sudo dnf install -y dnf-plugin-system-upgrade
      Write-Debug 'downloading system updates'
      sudo dnf system-upgrade download
      if (!$env:WSL_DISTRO_NAME) {
        Write-Debug 'doing release upgrade'
        sudo dnf system-upgrade reboot
      }
    }
    break
  }
}
