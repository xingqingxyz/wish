install_packages() {
  local packages=(
    bat
    clang
    cmake
    diskus
    fd
    fzf
    gh
    git
    git-delta
    golang
    hexyl
    hyperfine
    make
    msedit
    neovim-nightly
    mandoc
    nodejs
    openssh
    ripgrep
    termux-services
    bash-completion
    ninja
  )
  pkg install -y "${packages[@]}"
}

install_extra_packages() {
  # rustup
  curl -sSf https://sh.rustup.rs | bash -s -- -y
  rustup update
  rustup component add clippy
}

enable_services() {
  local services=(
    sshd
  )
  for service in "${services[@]}"; do
    sv-enable "$service"
  done
}

start() {
  local dir=${BASH_SOURCE[0]%/*}
  . "$dir/termux_export_environment.sh"
  enable_services
  install_packages
  install_extra_packages
}

if [ $# = 0 ]; then
  start
else
  echo "Usage: $0" >&2
  exit 1
fi
