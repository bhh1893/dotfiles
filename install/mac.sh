# shellcheck shell=bash
# macOS steps for install.sh (sourced).

BREW_FORMULAE=(
  neovim git lazygit git-delta ripgrep fd fzf bat eza zoxide starship tmux
  zsh-autosuggestions zsh-syntax-highlighting stow
  tree-sitter-cli python openjdk node gh herdr
  yazi ffmpeg-full sevenzip jq poppler resvg imagemagick-full
)
BREW_CASKS=(font-hack-nerd-font wezterm)

# missing_from <installed list> <package>...: prints the packages not in the list
missing_from() {
  local installed=$1 pkg
  shift
  for pkg in "$@"; do
    if ! grep -qx "$pkg" <<<"$installed"; then
      echo "$pkg"
    fi
  done
}

os_install_packages() {
  if ! command -v brew >/dev/null; then
    local candidate
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      if [ -x "$candidate" ]; then
        eval "$("$candidate" shellenv)"
        break
      fi
    done
  fi
  command -v brew >/dev/null || die "Homebrew is required: https://brew.sh"
  export HOMEBREW_NO_ENV_HINTS=1 NONINTERACTIVE=1

  local missing
  missing=$(missing_from "$(brew list --formula -1)" "${BREW_FORMULAE[@]}")
  if [ -n "$missing" ]; then
    log "brew install $(tr '\n' ' ' <<<"$missing")"
    # shellcheck disable=SC2086 # one word per package
    brew install $missing
    mark_changed
    # Keg-only builds: link them so yazi finds ffmpeg and magick
    if grep -qx ffmpeg-full <<<"$missing"; then
      brew link ffmpeg-full imagemagick-full -f --overwrite
    fi
  fi

  missing=$(missing_from "$(brew list --cask -1)" "${BREW_CASKS[@]}")
  if [ -n "$missing" ]; then
    log "brew install --cask $(tr '\n' ' ' <<<"$missing")"
    # shellcheck disable=SC2086 # one word per package
    brew install --cask $missing
    mark_changed
  fi
}

os_stow() {
  stow_top zsh tmux starship nvim lazygit claude wezterm
  stow_nested herdr
}

os_login_shell() {
  dscl . -read "/Users/$USER" UserShell | awk '{print $2}'
}
