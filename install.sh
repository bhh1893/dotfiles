#!/usr/bin/env bash
# Sets up this machine from the dotfiles repo (Ubuntu or macOS).
#
# Contract with the caller (Ansible):
#   - never prompts; run as the target user (passwordless sudo on Linux)
#   - idempotent: a second run changes nothing
#   - prints the line DOTFILES_CHANGED on stdout if (and only if) it changed anything
#   - exits non-zero on any failure
#
# Env: DOTFILES_SKIP_SKILLS=1 skips the agent skills step (for hosts without Node).
set -euo pipefail

DOTFILES_DIR="$(dirname "$(realpath "$0")")"
USER=${USER:-$(id -un)}
export USER
CHANGED=0
NEED_STOW=0

log() { printf '==> %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }
mark_changed() { CHANGED=1; }

# Reported on every exit path, so a half-finished run is still flagged as changed
report() {
  if [ "$CHANGED" -eq 1 ]; then
    echo DOTFILES_CHANGED
  fi
}
trap report EXIT

ensure_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    mark_changed
  fi
}

# resolve <path>: absolute path with symlinks followed, or "?" if it can't be resolved
resolve() { realpath "$1" 2>/dev/null || echo '?'; }

# ---- Stow -----

# Moves a conflicting target aside, never overwriting an earlier backup
back_up() {
  local target=$1 bak
  bak="$target.pre-dotfiles"
  if [ -e "$bak" ] || [ -L "$bak" ]; then
    bak="$bak.$(date +%s)"
  fi
  log "backing up $target -> $bak"
  mv "$target" "$bak"
  mark_changed
}

# reconcile_pkg <package root>: backs up anything in $HOME that would conflict with
# the package's files (so stow never needs --adopt) and sets NEED_STOW=1 if any
# file is not linked into $HOME yet.
reconcile_pkg() {
  local root=$1 file rel rest comp prefix target
  while IFS= read -r file; do
    rel=${file#"$root"/}
    rest=$rel
    prefix=
    while :; do
      comp=${rest%%/*}
      prefix=${prefix:+$prefix/}$comp
      target=$HOME/$prefix
      if [ -L "$target" ]; then
        # Stow only owns relative links; an absolute link from a manual `ln -s` to the
        # same file still makes stow report a conflict
        if [ "$(resolve "$target")" != "$(resolve "$root/$prefix")" ] ||
          [[ "$(readlink "$target")" == /* ]]; then
          back_up "$target"
          NEED_STOW=1
        fi
        break # linked into the repo (or just backed up): nothing below can conflict
      elif [ ! -e "$target" ]; then
        NEED_STOW=1
        break
      elif [ -d "$target" ] && [ "$rest" != "$comp" ]; then
        rest=${rest#*/} # real directory on the way down: look one level deeper
      else
        back_up "$target" # real file, or a real directory where the package has a file
        NEED_STOW=1
        break
      fi
    done
  done < <(find "$root" \( -type f -o -type l \) | sort)
}

# stow_group <stow dir> <package>...: links the packages into $HOME
stow_group() {
  local dir=$1 pkg
  shift
  NEED_STOW=0
  for pkg in "$@"; do
    reconcile_pkg "$dir/$pkg"
  done
  if [ "$NEED_STOW" -eq 1 ]; then
    log "stow $*"
    stow -d "$dir" -t "$HOME" "$@"
    mark_changed
  fi
}

# stow_top <package>...: packages that sit at the repo root
stow_top() { stow_group "$DOTFILES_DIR" "$@"; }

# stow_nested <tool>: <tool>/<tool>-common plus <tool>/<tool>-<os>, whichever exist
stow_nested() {
  local tool=$1 pkgs=() pkg
  for pkg in "$tool-common" "$tool-$DOTFILES_OS"; do
    if [ -d "$DOTFILES_DIR/$tool/$pkg" ]; then
      pkgs+=("$pkg")
    fi
  done
  if [ "${#pkgs[@]}" -gt 0 ]; then
    stow_group "$DOTFILES_DIR/$tool" "${pkgs[@]}"
  fi
}

# ---- Shared steps -----

set_login_shell() {
  local zsh_path current
  zsh_path=$(command -v zsh) || die "zsh is not installed"
  current=$(os_login_shell)
  if [ "$current" != "$zsh_path" ]; then
    log "setting login shell to $zsh_path"
    sudo chsh -s "$zsh_path" "$USER"
    mark_changed
  fi
}

install_fzf_git() {
  if [ ! -d "$HOME/fzf-git.sh" ]; then
    log "cloning fzf-git"
    git clone --depth 1 https://github.com/junegunn/fzf-git.sh.git "$HOME/fzf-git.sh"
    mark_changed
  fi
}

install_bat_theme() {
  local theme_dir theme themes
  theme_dir="$(bat --config-dir)/themes"
  theme=$theme_dir/tokyonight_night.tmTheme
  if [ ! -f "$theme" ]; then
    log "fetching bat tokyonight theme"
    mkdir -p "$theme_dir"
    curl -fsSL -o "$theme.tmp" \
      https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
    mv "$theme.tmp" "$theme"
    mark_changed
  fi
  # No pipe into grep -q: bat would die of SIGPIPE and pipefail would fail the script
  themes=$(bat --list-themes)
  if ! grep -qx tokyonight_night <<<"$themes"; then
    log "building bat cache"
    bat cache --build
    mark_changed
  fi
}

# The skills CLI's own restore command (experimental_install) only reads a project
# skills-lock.json, not the global ~/.agents/.skill-lock.json, so install each lock
# entry directly. Installs the latest upstream version of each skill, not the pinned hash.
restore_skills() {
  if [ "${DOTFILES_SKIP_SKILLS:-0}" = 1 ]; then
    log "skipping agent skills (DOTFILES_SKIP_SKILLS=1)"
    return
  fi
  local lock=$DOTFILES_DIR/skills/.skill-lock.json entries source name src sources args
  if ! command -v node >/dev/null || ! command -v npx >/dev/null; then
    die "node/npx not found: Node.js is required to restore agent skills (or set DOTFILES_SKIP_SKILLS=1)"
  fi
  entries=$(node -e '
    const lock = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
    for (const [name, s] of Object.entries(lock.skills)) console.log(s.source + "\t" + name);
  ' "$lock")
  sources=$(cut -f1 <<<"$entries" | sort -u)
  while IFS= read -r src; do
    args=()
    while IFS=$'\t' read -r source name; do
      if [ "$source" = "$src" ] && [ ! -e "$HOME/.claude/skills/$name" ]; then
        args+=(-s "$name")
      fi
    done <<<"$entries"
    if [ "${#args[@]}" -gt 0 ]; then
      log "installing skills from $src: ${args[*]}"
      DISABLE_TELEMETRY=1 npx -y skills add "$src" -g -a claude-code -y "${args[@]}"
      mark_changed
    fi
  done <<<"$sources"
}

# ---- Main -----

export PATH="$HOME/.local/bin:$PATH"
export DEBIAN_FRONTEND=noninteractive

case "$(uname -s)" in
  Linux) DOTFILES_OS=linux ;;
  Darwin) DOTFILES_OS=mac ;;
  *) die "unsupported OS: $(uname -s)" ;;
esac
# shellcheck source=/dev/null
source "$DOTFILES_DIR/install/$DOTFILES_OS.sh"

command -v git >/dev/null || die "git is required"

os_install_packages
command -v stow >/dev/null || die "stow is not installed"

# Real directories stow must not replace with a single symlink into the repo
# (apps write their own state there)
ensure_dir "$HOME/.config"
ensure_dir "$HOME/.local/bin"
ensure_dir "$HOME/.claude"

os_stow
set_login_shell
install_fzf_git
install_bat_theme
restore_skills
