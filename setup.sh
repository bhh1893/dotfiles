#!/usr/bin/env bash
# setup.sh - bootstrap a new machine: zsh, oh-my-zsh, pure, fzf, vim-plug, .zshrc, .vimrc
# Usage: curl -fsSL https://raw.githubusercontent.com/<you>/<repo>/main/setup.sh | bash
#    or: git clone <repo> && cd <repo> && ./setup.sh
set -euo pipefail

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[warn] %s\033[0m\n' "$*" >&2; }

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  command -v sudo >/dev/null 2>&1 && SUDO="sudo"
fi

# ---------------------------------------------------------------------------
# 1. System packages
# ---------------------------------------------------------------------------
install_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update -y
    $SUDO apt-get install -y zsh git curl vim tmux build-essential cmake python3-dev
  elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y zsh git curl vim-enhanced tmux gcc gcc-c++ make cmake python3-devel
  elif command -v pacman >/dev/null 2>&1; then
    $SUDO pacman -Sy --noconfirm zsh git curl vim tmux base-devel cmake python
  elif command -v brew >/dev/null 2>&1; then
    brew install zsh git curl vim tmux cmake python
  else
    warn "No supported package manager found. Install zsh, git, curl, vim manually."
    return 1
  fi
}

log "Installing system packages"
install_packages

# ---------------------------------------------------------------------------
# 2. vim-plug
# ---------------------------------------------------------------------------
log "Installing vim-plug"
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# ---------------------------------------------------------------------------
# 3. oh-my-zsh (unattended: don't switch shell, don't overwrite .zshrc, don't launch zsh)
# ---------------------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "oh-my-zsh already installed, skipping"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_if_missing() {
  local url="$1" dest="$2"
  if [ -d "$dest" ]; then
    echo "  already present: $dest"
  else
    git clone --depth 1 "$url" "$dest"
  fi
}

# ---------------------------------------------------------------------------
# 4. fzf (from git so it's recent and works on any distro)
# ---------------------------------------------------------------------------
log "Installing fzf"
clone_if_missing https://github.com/junegunn/fzf.git "$HOME/.fzf"
"$HOME/.fzf/install" --bin
mkdir -p "$HOME/bin"
ln -sf "$HOME/.fzf/bin/fzf" "$HOME/bin/fzf"

# ---------------------------------------------------------------------------
# 5. zsh plugins + pure prompt
# ---------------------------------------------------------------------------
log "Installing zsh plugins"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/joshskidmore/zsh-fzf-history-search.git \
  "$ZSH_CUSTOM/plugins/zsh-fzf-history-search"

log "Installing pure prompt"
mkdir -p "$HOME/.zsh"
clone_if_missing https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"

# ---------------------------------------------------------------------------
# 6. Write config files (existing ones are backed up first)
# ---------------------------------------------------------------------------
backup() {
  if [ -f "$1" ]; then
    local b="$1.bak.$(date +%Y%m%d%H%M%S)"
    cp "$1" "$b"
    echo "  backed up $1 -> $b"
  fi
}

log "Writing ~/.vimrc"
backup "$HOME/.vimrc"
cat > "$HOME/.vimrc" <<'VIMRC_EOF'
"   *** .vimrc File ***
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ","

set rtp+=/usr/share/fonts/NovaMono

" Plugins
call plug#begin('~/.vim/plugged')
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-unimpaired'
  Plug 'tpope/vim-vinegar'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'https://github.com/lilydjwg/colorizer'
  Plug 'Valloric/YouCompleteMe'
call plug#end()

" Plugin adjustments
"let g:airline_powerline_fonts = 1
" let g:airline_theme='ayu_mirage'
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#fnamemod = ':t'
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
let g:AutoPairsShortcutToggle = '<C-b>'
" --------------------------
let g:airline_theme='bubblegum'
let g:airline_extensions = []
let g:airline_symbols = {}
let g:airline_symbols.maxlinenr= ''
let g:airline_symbols.linenr= ' : '
let g:airline_symbols.colnr = ' : '
let g:airline_mode_map = {
\ '__'     : '-',
\ 'c'      : 'C',
\ 'i'      : 'I',
\ 'ic'     : 'I',
\ 'ix'     : 'I',
\ 'n'      : 'N',
\ 'multi'  : 'M',
\ 'ni'     : 'N',
\ 'no'     : 'N',
\ 'R'      : 'R',
\ 'Rv'     : 'R',
\ 's'      : 'S',
\ 'S'      : 'S',
\ 't'      : 'T',
\ 'v'      : 'V',
\ 'V'      : 'V',
\ "\<C-v>" : 'V',
\ }


" --------------------------
" Personal useful shortcuts
map <space> :
inoremap <leader><leader> <Esc>/<++><Enter>"_c4l<Esc>:noh<Enter>a
vnoremap <leader><leader> <Esc>/<++><Enter>"_c4l<Esc>:noh<Enter>a
nmap K i<CR><ESC>k$a <ESC>
map <leader>] :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Enable/disable spellchecker
imap <leader>s <Esc>:setlocal spell! spelllang=en_us<CR>a
map <leader>s :setlocal spell! spelllang=en_us<CR>

set cursorline
hi CursorLine cterm=undercurl ctermfg=None

" Buffer Settings
" set hidden
" nmap <leader>T :enew<CR>
nmap <leader>n :bnext<CR>
nmap <leader>b :bprevious<CR>
" nnoremap <down> :buffers<CR>:buffer<Space>
" nmap <leader>qq :bd<CR>
" nmap <leader>q! :bd!<CR>
" nmap <leader>wq :w<CR>:bd<CR>

" Explore Settings
let g:netrw_banner       = 0
let g:netrw_keepdir      = 0
let g:netrw_liststyle    = 3 " or 3
let g:netrw_sort_options = 'i'
nmap <leader>v :Vex<CR>:vertical resize 30<CR>

" Windows settings
set splitbelow splitright
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Colorscheme settings
syntax enable
set number relativenumber
let g:solarized_termcolors=16
set t_Co=256
set foldcolumn=1

" Use spaces instead of tabs
set expandtab
set shiftwidth=2
set tabstop=2

autocmd FileType cpp setlocal shiftwidth=4 softtabstop=4 expandtab
autocmd FileType javascript setlocal shiftwidth=2 softtabstop=2 expandtab
autocmd FileType html setlocal shiftwidth=2 softtabstop=2 expandtab

" Disable highlighting and auto-comment
map ,k :noh<CR>
imap ,k <Esc>:noh<CR>a
autocmd Filetype * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Copy between vim and system clipboard
vnoremap <C-c> "+y
map <C-p> "+P

set wildmenu

" Return to last edit position when opening files
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Some sets
set so=2
set nocp

set ignorecase
set smartcase
set hlsearch
set incsearch

set t_vb=
set tm=500
set noerrorbells
set novisualbell
set noshowmode

set showmatch
set history=500

set autoread
set ai
set si

set wrap
set linebreak
set nolist
set showcmd

set nobackup
set nowb
set noswapfile
set mouse=a
"set paste

"""""""""""""""""""""""""""""""""""""""""""""""""""

" Leader + C to copy the visual selection to the system clipboard
vnoremap <Leader>c "+y

" Leader + V to paste the content of the system clipboard
nnoremap <Leader>p "+p
VIMRC_EOF

log "Writing ~/.zshrc"
backup "$HOME/.zshrc"
cat > "$HOME/.zshrc" <<'ZSHRC_EOF'
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="agnoster"
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    web-search
    copypath
    copyfile
    zsh-fzf-history-search
)

source $ZSH/oh-my-zsh.sh
fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

function chpwd() {
    emulate -L zsh
    ls
}

export PATH="$HOME/bin:$PATH"
alias k="kubectl"
alias attach='tmux a -t '
alias detach='tmux detach'
alias tlist='tmux list-session'
ZSHRC_EOF

# ---------------------------------------------------------------------------
# 6b. Git settings
# ---------------------------------------------------------------------------
log "Configuring git"
# Print `git branch` output directly instead of opening it in less
git config --global pager.branch false

# ---------------------------------------------------------------------------
# 7. Install vim plugins
# ---------------------------------------------------------------------------
log "Installing vim plugins (PlugInstall)"
vim -es -u "$HOME/.vimrc" -i NONE -c "PlugInstall --sync" -c "qa" </dev/null || \
  warn "PlugInstall had issues; open vim and run :PlugInstall manually."

# YouCompleteMe needs a compiled component to work
if [ -d "$HOME/.vim/plugged/YouCompleteMe" ]; then
  log "Building YouCompleteMe (this can take a few minutes)"
  ( cd "$HOME/.vim/plugged/YouCompleteMe" && python3 install.py ) || \
    warn "YCM build failed. Check its docs for required dependencies, then re-run: python3 ~/.vim/plugged/YouCompleteMe/install.py"
fi

# ---------------------------------------------------------------------------
# 8. Make zsh the default shell
# ---------------------------------------------------------------------------
ZSH_BIN="$(command -v zsh || true)"
if [ -n "$ZSH_BIN" ] && [ "${SHELL:-}" != "$ZSH_BIN" ]; then
  log "Setting zsh as the default shell"
  grep -qx "$ZSH_BIN" /etc/shells 2>/dev/null || echo "$ZSH_BIN" | $SUDO tee -a /etc/shells >/dev/null
  chsh -s "$ZSH_BIN" || warn "chsh failed; run 'chsh -s $ZSH_BIN' manually."
fi

log "Done. Log out and back in (or run 'exec zsh') to start using your new setup."
