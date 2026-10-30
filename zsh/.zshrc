# ~/.zshrc
# Copy into place: cp ~/dotfiles/zsh/.zshrc ~/.zshrc
# or link it:      ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc

# ---- Environment -----

# Config files in ~/.config (lazygit looks in ~/Library/Application Support otherwise)
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="nvim"
alias vim="nvim"

# Colored output from macOS's built-in tools (ls, etc.)
export CLICOLOR=1

# Ctrl+w / Alt+Backspace / Alt+b / Alt+f stop at / . _ - and other punctuation,
# so Ctrl+w on ~/dotfiles/nvim deletes "nvim", not the whole path
WORDCHARS=''

# Homebrew's Java (brew doesn't link openjdk onto the PATH)
export PATH="$(brew --prefix openjdk)/bin:$PATH"

# ---- History -----

HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# ---- Completion -----

# Turn on zsh's completion system and color its lists like ls
autoload -Uz compinit && compinit
zmodload zsh/complist
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Tab completion ignores case

# Grey suggestions from history as you type; → accepts, Alt+f accepts a word
[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Case-insensitive history suggestions: typing "GIT st" suggests "git status".
# Walks history newest-first comparing lowercased text (no patterns, so * [ ] etc.
# are safe); the suggestion keeps what you typed and adds the rest of the entry.
_zsh_autosuggest_strategy_history_ci() {
  emulate -L zsh
  local typed=${(L)1} n entry
  for n in ${(Onk)history}; do
    entry=${history[$n]}
    if [[ ${(L)entry[1,${#1}]} == "$typed" ]]; then
      typeset -g suggestion="$1${entry:${#1}}"
      return
    fi
  done
}
ZSH_AUTOSUGGEST_STRATEGY=(history_ci)

# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# --- setup fzf theme (Iceberg) ---
fg="#C6C8D1"
bg="#161821"
bg_highlight="#2A3158"
purple="#A093C7"
blue="#84A0C6"
cyan="#89B8C2"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# fzf-git: Ctrl+g key bindings for git objects (clone: see README)
[ -f ~/fzf-git.sh/fzf-git.sh ] && source ~/fzf-git.sh/fzf-git.sh

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ----- Bat (better cat) -----

export BAT_THEME=tokyonight_night

alias cat="bat --paging=never"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ---- Eza (better ls) -----

alias ls="eza --icons=always"
alias ll="eza -l --icons=always --git --group-directories-first"
alias la="eza -la --icons=always --git --group-directories-first"
alias lt="eza --tree --level=2 --icons=always"

# ---- Prompt -----

eval "$(starship init zsh)"

# ---- Syntax highlighting (must stay last) -----

# Commands turn green when valid, red when mistyped
[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
