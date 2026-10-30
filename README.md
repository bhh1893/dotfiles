# bhh1893 setup

My Neovim config and the steps to set up a new machine. It's written for macOS.

`nvim/` is the source of truth. Edit it here, then copy it to `~/.config/nvim` on a new machine.

### mini.nvim modules

| Module | Keys |
|---|---|
| ai | Text objects: `a` argument, `f` function call, `b` bracket, `q` quote, plus `n`/`l` for next/last (`cin"`) |
| align | `ga` / `gA` align text |
| comment | `gc` / `gcc` toggle comments |
| pairs | Auto-closes brackets and quotes |
| move | Alt+hjkl moves lines and selections |
| surround | `gsa` add, `gsd` delete, `gsr` replace surroundings (on `gs` because flash uses `s`) |
| icons | File and language icons |
| completion | Popup as you type, Tab / Shift-Tab to move, Ctrl+y to accept |
| misc | Reopens files at the last cursor position; `<leader>z` zooms the window |
| trailspace | Highlights trailing whitespace; `<leader>cw` trims it |
| starter | Start screen when Neovim opens without a file |
| cursorword | Underlines other uses of the word under the cursor |
| indentscope | Line showing the current indent scope; `ii` / `ai` text objects, `[i` / `]i` jumps |
| clue | Pause after `<leader>`, `g`, `[`, `]`, `z`, `"`, `'` or Ctrl+w to see what can follow |

### flash.nvim

| Keys | Action |
|---|---|
| `s` | Type a few characters, then the label next to the match to jump there |
| `S` | Select a Treesitter node (function, block, …) by label |
| `f` / `t` / `F` / `T` | Work across lines with highlighted targets; press again to repeat |
| `r` (after an operator) | Remote: act on text elsewhere without moving (`yr` + label + motion) |
| `R` (after an operator / in visual) | Treesitter search |
| Ctrl+s (in `/` search) | Toggle flash labels on the search |

## New Mac setup

### 1. Command Line Tools and Homebrew

```bash
xcode-select --install
```

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

On Apple Silicon, put brew on your PATH (the installer prints this too):

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. Tools

```bash
brew install neovim git lazygit git-delta ripgrep fd fzf starship
```

For coding in Neovim (Treesitter parsers, Python and Java language servers):

```bash
brew install tree-sitter-cli python openjdk
```

```bash
brew install --cask font-hack-nerd-font
```

Optional, for GitHub from the terminal (`gh pr create`, `gh pr checkout`, …):

```bash
brew install gh
```

### 3. Terminal settings

- **Font:** set the terminal font to **Hack Nerd Font**, or icons show up as boxes.
- **Option as Alt:** mini.move uses Alt+hjkl, and Mac terminals don't send Option as Alt by default.
  - iTerm2: Settings → Profiles → Keys → Left Option key = **Esc+**
  - Ghostty: `macos-option-as-alt = true`
  - kitty: `macos_option_as_alt yes`
  - Terminal.app: Settings → Profiles → Keyboard → **Use Option as Meta key**

### 4. Neovim config

```bash
git clone https://github.com/bhh1893/my_setup_bhh.git ~/dotfiles
```

```bash
mkdir -p ~/.config && cp -R ~/dotfiles/nvim ~/.config/nvim
```

Open `nvim`. lazy.nvim installs itself and every plugin on the first launch, at the versions in `lazy-lock.json`. Restart Neovim once it finishes. Treesitter parsers build in the background, and Mason installs the language servers the first time you open a file (`:Mason` shows progress).

A copy doesn't stay in sync with the repo. To edit the config in the repo and have Neovim pick it up directly, link it instead of copying:

```bash
ln -s ~/dotfiles/nvim ~/.config/nvim
```

### 5. Shell (`~/.zshrc`)

```bash
cat >> ~/.zshrc <<'EOF'

# Config files in ~/.config (lazygit looks in ~/Library/Application Support otherwise)
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="nvim"

# Homebrew's Java (brew doesn't link openjdk onto the PATH)
export PATH="$(brew --prefix openjdk)/bin:$PATH"

# Prompt
eval "$(starship init zsh)"

# fzf keybindings and completion (Ctrl+R history, Ctrl+T files, Alt+C cd)
# source <(fzf --zsh)
EOF
```

```bash
source ~/.zshrc
```

Uncomment the fzf line once you're ready to use it.

### 6. Git

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Neovim as the editor, diff tool and merge tool:

```bash
git config --global core.editor nvim
git config --global diff.tool nvimdiff
git config --global merge.tool nvimdiff
git config --global mergetool.keepBackup false
```

delta for diffs:

```bash
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.side-by-side true
```

Aliases:

```bash
git config --global alias.lg "log --oneline --graph --all --decorate"
git config --global alias.st "status -sb"
```

### 7. lazygit

Open files from lazygit (`e`) in Neovim:

```bash
mkdir -p ~/.config/lazygit && printf "os:\n  editPreset: 'nvim'\n" > ~/.config/lazygit/config.yml
```

### 8. SSH key for GitHub

```bash
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_github
```

```bash
cat >> ~/.ssh/config <<'EOF'

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_github
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes
EOF
```

```bash
ssh-add --apple-use-keychain ~/.ssh/id_github
```

```bash
pbcopy < ~/.ssh/id_github.pub
```

Paste the key at GitHub → Settings → SSH and GPG keys → New SSH key (or run `gh ssh-key add ~/.ssh/id_github.pub` if you installed `gh`). Then check it:

```bash
ssh -T git@github.com
```

It should say `Hi <username>! You've successfully authenticated`.

## Windows

On Windows, Neovim reads its config from `%LOCALAPPDATA%\nvim` unless the `XDG_CONFIG_HOME` user environment variable points at `C:\Users\<you>\.config`. On this machine `~/.config/nvim` is a directory junction to this repo's `nvim/` folder, so edits here take effect straight away:

```powershell
cmd /c mklink /J "$env:USERPROFILE\.config\nvim" "$env:USERPROFILE\Desktop\Work\dotfiles\nvim"
```
