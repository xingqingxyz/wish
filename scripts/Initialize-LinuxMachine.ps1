using namespace System.Runtime.InteropServices

if ((id -u) -cne '0') {
  throw 'needs sudo'
}
# data dirs for GithubRelease
New-Item -ItemType Directory /usr/local/share/jar -Force
# init machine env
Set-Region 'LoadMachineEnv' @'
if [ -f /etc/.env ]; then
  while read -r line; do
    if [[ $line =~ ^\s*# ]]; then
      continue
    fi
    export "$line"
  done < /etc/.env
fi
'@ /etc/profile.d/sh.local -Force
if ($PSVersionTable.OS.StartsWith('Fedora ')) {
  # dnf copr
  $coprs = @(
    'avengemedia/dms'
    'scottames/ghostty'
  )
  dnf copr enable -y $coprs
  # remove some packages
  $pkgs = @(
    'evince'
    'gnome-text-editor'
    'ibus'
    'nano'
    'ptyxis'
    'tree'
    'vim-minimal'
    'wcurl'
  )
  dnf remove -y $pkgs
}
elseif ($PSVersionTable.OS.StartsWith('Ubuntu ')) {
  $label = (Get-Content -LiteralPath /etc/os-release | Select-String -Raw -SimpleMatch UBUNTU_CODENAME=).Split('=', 2)[1]
  # ubuntu
  New-Item /etc/apt/sources.list.d/ubuntu.sources -Value @"
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
Suites: $label $label-updates $label-backports $label-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: $label-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
"@ -Force
  # google
  New-Item /etc/apt/sources.list.d/google-chrome.sources -Value @'
X-Repolib-Name: Google Chrome
Types: deb
URIs: https://dl.google.com/linux/chrome-stable/deb/
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/google-chrome.gpg
'@ -Force
  # microsoft
  New-Item /etc/apt/sources.list.d/microsoft-edge.sources -Value @'
Types: deb
URIs: https://packages.microsoft.com/repos/edge
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/microsoft.gpg
'@ -Force
  New-Item /etc/apt/sources.list.d/vscode.sources -Value @'
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/microsoft.gpg
'@ -Force
  # add python symlink
  ln -sf python3 /usr/bin/python
  # remove some packages
  $pkgs = @(
    'gnome-text-editor'
    'ibus'
    'nano'
    'ptyxis'
  )
  apt purge -y --auto-remove $pkgs
}
elseif ($PSVersionTable.OS.StartsWith('Debian ') -and
  [RuntimeInformation]::OSArchitecture -eq [Architecture]::Arm64) {
  $label = (Get-Content -LiteralPath /etc/os-release | Select-String -Raw -SimpleMatch DEBIAN_CODENAME=).Split('=', 2)[1]
  # llvm
  Invoke-RestMethod 'https://apt.llvm.org/llvm-snapshot.gpg.key' -OutFile /etc/apt/trusted.gpg.d/apt.llvm.org.asc/etc/apt/trusted.gpg.d/apt.llvm.org.asc
  New-Item /etc/apt/sources.list.d/llvm-toolchain.sources -Value @"
Types: deb
URIs: http://apt.llvm.org/$label
Suites: llvm-toolchain-$label-22
Components: main
Signed-By: /etc/apt/trusted.gpg.d/apt.llvm.org.asc
"@ -Force
  # remove some packages
  $pkgs = @(
    'nano'
    'phony'
    'vim-tiny'
  )
  apt purge -y --auto-remove $pkgs
}
