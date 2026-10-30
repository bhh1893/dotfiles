# bhh1893 setup

My Neovim config and the steps to set up a new machine. It's written for macOS.

`nvim/` is the source of truth. Edit it here, then copy it to `~/.config/nvim` on a new machine.

## What's in `nvim/`

| File                          | What it does                                                                                      |
| ----------------------------- | ------------------------------------------------------------------------------------------------- |
| `init.lua`                    | Loads the files below in order                                                                    |
| `lua/vim_config.lua`          | Options (leader is Space, line numbers, clipboard, …)                                             |
| `lua/plugin.lua`              | Bootstraps lazy.nvim and loads everything in `lua/plugins/`                                       |
| `lua/keys.lua`                | Window navigation and splits (`<leader>hjkl`, `<leader>v/s`), resizing (Ctrl+hjkl)                |
| `lua/plugins/navigation.lua`  | oil.nvim (`<leader>e`), Snacks pickers (`<leader>f` files, `<leader>/` grep, `<leader>b` buffers) |
| `lua/plugins/git.lua`         | gitsigns, lazygit (`<leader>gg`), Snacks git pickers, diffview (all under `<leader>g`)            |
| `lua/plugins/mini-addons.lua` | mini.ai, align, comment, pairs, move (Alt+hjkl), surround, icons                                  |
| `lua/plugins/markdown.lua`    | render-markdown: formatted markdown in the buffer (`<leader>m` toggles)                           |
| `lua/plugins/dimmer.lua`      | vimade: dims inactive windows                                                                     |
| `lua/plugins/statusline.lua`  | mini.statusline                                                                                   |
| `lua/plugins/colorscheme.lua` | Colorscheme                                                                                       |
| `lazy-lock.json`              | Pinned plugin versions                                                                            |

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

```bash
brew install --cask font-hack-nerd-font
```

Optional, for GitHub from the terminal (`gh pr create`, `gh pr checkout`, …):

```bash
brew install gh
```

| Tool                  | Used for                                                                        |
| --------------------- | ------------------------------------------------------------------------------- |
| `neovim`              | The editor                                                                      |
| `git`                 | Newer than Apple's, and lazy.nvim uses it to install plugins                    |
| `lazygit`             | Git interface, `<leader>gg` in Neovim                                           |
| `git-delta`           | Readable diffs in `git diff`, `git log -p`, `git show` (the command is `delta`) |
| `ripgrep`             | Text search, `<leader>/` in Neovim                                              |
| `fd`                  | Fast file finding, `<leader>f` in Neovim                                        |
| `fzf`                 | Fuzzy finder for the shell (to set up later)                                    |
| `starship`            | Shell prompt with git branch and status                                         |
| `font-hack-nerd-font` | Hack font with the icons the statusline and pickers use                         |

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

Open `nvim`. lazy.nvim installs itself and every plugin on the first launch, at the versions in `lazy-lock.json`. Restart Neovim once it finishes.

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
