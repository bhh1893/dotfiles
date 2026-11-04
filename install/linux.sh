# shellcheck shell=bash
# Ubuntu steps for install.sh (sourced). Written against Ubuntu 26.04, where every
# package below is in the archive and neovim is 0.11.x (this config needs >= 0.11).

APT_PACKAGES=(
  zsh tmux neovim ripgrep fd-find bat fzf eza zoxide starship lazygit git-delta stow curl
  zsh-autosuggestions zsh-syntax-highlighting
)

os_install_packages() {
  local missing=() pkg
  for pkg in "${APT_PACKAGES[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed'; then
      missing+=("$pkg")
    fi
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    log "apt install ${missing[*]}"
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
    mark_changed
  fi

  # Ubuntu names these binaries fdfind and batcat
  ensure_dir "$HOME/.local/bin"
  local pair src dest
  for pair in fdfind:fd batcat:bat; do
    src=$(command -v "${pair%%:*}") || die "${pair%%:*} not found after apt install"
    dest=$HOME/.local/bin/${pair##*:}
    if [ "$(readlink "$dest" 2>/dev/null || true)" != "$src" ]; then
      ln -sfn "$src" "$dest"
      mark_changed
    fi
  done

  local version
  version=$(nvim --version | sed -n '1s/^NVIM v\([0-9]*\.[0-9]*\).*/\1/p')
  case $version in
    0.1[1-9] | [1-9].*) ;;
    *) die "neovim '$version' is too old (need >= 0.11); install the upstream release binary" ;;
  esac
}

# Headless VM: no wezterm or herdr
os_stow() {
  stow_top zsh tmux starship nvim lazygit claude
}

os_login_shell() {
  getent passwd "$USER" | cut -d: -f7
}
