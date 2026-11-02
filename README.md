# bhh1893 setup

Install steps for a new Mac. `nvim/` is the source of truth for the Neovim config. For keymaps and how to use everything, see [CHEATSHEET.md](CHEATSHEET.md).

## 1. Command Line Tools and Homebrew

Install Apple's developer tools (git, clang, make):

```bash
xcode-select --install
```

Install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Put brew on your PATH (Apple Silicon; the installer prints this too):

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## 2. Tools

Editor, git tools and terminal tools:

```bash
brew install neovim git lazygit git-delta ripgrep fd fzf bat eza zoxide starship tmux zsh-autosuggestions zsh-syntax-highlighting
```

| Tool | What it's for |
|---|---|
| `neovim` | The editor |
| `git` | Newer than Apple's; lazy.nvim uses it to install plugins |
| `lazygit` | Terminal git interface (`<leader>gg` in Neovim) |
| `git-delta` | Syntax-highlighted, side-by-side git diffs (command: `delta`) |
| `ripgrep` | Fast text search (`rg`; `<leader>/` in Neovim) |
| `fd` | Fast file finder (`<leader>f` in Neovim, fzf in the shell) |
| `fzf` | Fuzzy finder for the shell: history, files, folders |
| `bat` | `cat` with syntax highlighting and line numbers |
| `eza` | `ls` with icons, colors, git status and a tree view |
| `zoxide` | Smarter `cd`: jumps to folders you visit often by part of their name |
| `starship` | Shell prompt showing git branch and status |
| `tmux` | Terminal multiplexer: split panes, windows, sessions that survive closing the terminal |
| `zsh-autosuggestions` | Grey suggestions from your history as you type |
| `zsh-syntax-highlighting` | Colors commands as you type: green if valid, red if mistyped |

For coding in Neovim (Treesitter parsers, Python and Java language servers):

```bash
brew install tree-sitter-cli python openjdk
```

Nerd Font with the icons Neovim, eza and starship use:

```bash
brew install --cask font-hack-nerd-font
```

WezTerm, the terminal app (config in section 11):

```bash
brew install --cask wezterm
```

Optional, GitHub from the terminal (`gh pr create`, `gh pr checkout`, …):

```bash
brew install gh
```

## 3. Terminal settings

Using WezTerm? Its config (section 11) already sets the font, Option as Alt and Iceberg colors; only the Ctrl+Space step below still applies.

- **Font:** set the terminal font to **Hack Nerd Font**, or icons show up as boxes.
- **Option as Alt:** needed for Alt keys (mini.move in Neovim, fzf's Alt+C).
  - iTerm2: Settings → Profiles → Keys → Left Option key = **Esc+**
  - Ghostty: `macos-option-as-alt = true`
  - kitty: `macos_option_as_alt yes`
  - Terminal.app: Settings → Profiles → Keyboard → **Use Option as Meta key**
- **Ctrl+Space for tmux:** macOS uses Ctrl+Space to switch input sources. Turn it off in System Settings → Keyboard → Keyboard Shortcuts → Input Sources, or tmux never sees it.
- **Colors (optional):** pick the **Iceberg** (dark) color scheme in your terminal so the shell matches Neovim, fzf and tmux. It's in [iTerm2-Color-Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes), which Ghostty includes.

## 4. Neovim config

Clone this repo:

```bash
git clone https://github.com/bhh1893/dotfiles.git ~/dotfiles
```

Copy the config into place:

```bash
mkdir -p ~/.config && cp -R ~/dotfiles/nvim ~/.config/nvim
```

Or link it instead, so edits in the repo apply straight away (every config below has the same choice):

```bash
mkdir -p ~/.config && ln -s ~/dotfiles/nvim ~/.config/nvim
```

Open `nvim`. lazy.nvim installs every plugin on first launch (versions pinned in `lazy-lock.json`); restart Neovim once it finishes. Treesitter parsers build in the background, and Mason installs the language servers the first time you open a file (`:Mason` shows progress).

## 5. Shell (`~/.zshrc`)

`zsh/.zshrc` sets up history, completion, autosuggestions, syntax highlighting, fzf (with fd, fzf-git and bat/eza previews), bat, eza and the starship prompt.

Get fzf-git (adds Ctrl+g key bindings for git branches, commits, files, …):

```bash
git clone https://github.com/junegunn/fzf-git.sh.git ~/fzf-git.sh
```

Install the tokyonight theme for bat (the `.zshrc` sets `BAT_THEME=tokyonight_night`):

```bash
mkdir -p "$(bat --config-dir)/themes"
curl -fsSL -o "$(bat --config-dir)/themes/tokyonight_night.tmTheme" \
  https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build
```

Copy the starship prompt config (path from `~`, git branch, time on the right, `>` on the next line):

```bash
mkdir -p ~/.config && cp ~/dotfiles/starship/starship.toml ~/.config/starship.toml
```

Or link it:

```bash
mkdir -p ~/.config && ln -sf ~/dotfiles/starship/starship.toml ~/.config/starship.toml
```

Back up the existing `~/.zshrc`, if there is one:

```bash
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.bak
```

Copy the repo's `.zshrc` into place:

```bash
cp ~/dotfiles/zsh/.zshrc ~/.zshrc
```

Or link it:

```bash
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
```

Load it in the current shell:

```bash
source ~/.zshrc
```

## 6. tmux

Copy the tmux config into place (prefix Ctrl+Space, Iceberg colors):

```bash
mkdir -p ~/.config/tmux && cp ~/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf
```

Or link it:

```bash
mkdir -p ~/.config/tmux && ln -sf ~/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf
```

Put the sessionizer on your PATH (prefix f: pick a project folder, switch to its session):

```bash
mkdir -p ~/.local/bin && cp ~/dotfiles/tmux/tmux-sessionizer ~/.local/bin/ && chmod +x ~/.local/bin/tmux-sessionizer
```

Or link it:

```bash
mkdir -p ~/.local/bin && ln -sf ~/dotfiles/tmux/tmux-sessionizer ~/.local/bin/tmux-sessionizer && chmod +x ~/dotfiles/tmux/tmux-sessionizer
```

Start tmux in the folder that holds your projects; prefix f then lists that folder and every project in it:

```bash
cd ~/code && tmux
```

## 7. lazygit

Open files from lazygit (`e`) in Neovim:

```bash
mkdir -p ~/.config/lazygit && printf "os:\n  editPreset: 'nvim'\n" > ~/.config/lazygit/config.yml
```

## 8. Git

Your identity for commits:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Neovim as the commit editor, diff tool and merge tool:

```bash
git config --global core.editor nvim
git config --global diff.tool nvimdiff
git config --global merge.tool nvimdiff
git config --global mergetool.keepBackup false
```

delta for `git diff`, `git log -p`, `git show` and `git add -p`:

```bash
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.side-by-side true
```

Short aliases (`git lg` history graph, `git st` short status):

```bash
git config --global alias.lg "log --oneline --graph --all --decorate"
git config --global alias.st "status -sb"
```

## 9. SSH key for GitHub

Create a key:

```bash
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_github
```

Tell ssh to use it for GitHub and keep the passphrase in the macOS Keychain:

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

Add the key to the agent and Keychain:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_github
```

Copy the public key, then paste it at GitHub → Settings → SSH and GPG keys → New SSH key (or run `gh ssh-key add ~/.ssh/id_github.pub`):

```bash
pbcopy < ~/.ssh/id_github.pub
```

Check it works (should say `Hi <username>! You've successfully authenticated`):

```bash
ssh -T git@github.com
```

## 10. Claude Code

Install Claude Code:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

`claude/AGENTS.md` holds my personal instructions for coding agents. Point Claude Code's global memory file at it with an import line, so every session loads it and edits in the repo apply straight away:

```bash
mkdir -p ~/.claude && echo '@~/dotfiles/claude/AGENTS.md' > ~/.claude/CLAUDE.md
```

The `.zshrc` adds short aliases (`cl`, `clc`, `clr`, …); see the cheat sheet.

## 11. WezTerm

`wezterm/wezterm.lua` sets Iceberg colors, Hack Nerd Font, both Option keys as Alt, no title bar and no tab bar (tmux does tabs). WezTerm reloads it on save.

Copy the config into place:

```bash
mkdir -p ~/.config && cp -R ~/dotfiles/wezterm ~/.config/wezterm
```

Or link it:

```bash
mkdir -p ~/.config && ln -s ~/dotfiles/wezterm ~/.config/wezterm
```

## 12. Herdr

Herdr is a desktop app for terminals and coding agents: spaces, tabs and panes, like tmux sessions, windows and panes. Use one or the other per project; tmux stays set up. `herdr/` holds the keys (tmux-style, see the cheat sheet), an Iceberg theme and the settings.

Link the keys and theme (Herdr reloads them live), and copy the settings, since Herdr writes to that file itself (zoom keys, settings window):

```bash
mkdir -p ~/.config/herdr-app/themes
ln -sf ~/dotfiles/herdr/keys.json ~/.config/herdr-app/keys.json
ln -sf ~/dotfiles/herdr/themes/iceberg.json ~/.config/herdr-app/themes/iceberg.json
cp ~/dotfiles/herdr/settings.json ~/.config/herdr-app/settings.json
```

macOS settings for Herdr's keys:

- **Option as Alt:** `herdr/settings.json` sets `option_as_alt` to `on`, so Option+key reaches Herdr and terminal programs as Alt (Option no longer types é, ü, …).
- **Ctrl+1–9 for spaces:** turn off "Switch to Desktop 1–9" in System Settings → Keyboard → Keyboard Shortcuts → Mission Control, or macOS takes those keys before Herdr sees them.

If a file is invalid, Herdr keeps the last good version and writes the reason to `~/.config/herdr-app/keys.error` (or `settings.error`).

## 13. Yazi

Terminal file manager with previews for images, video, PDFs and archives. In Neovim it opens in a float (`<leader>y`); in the shell, `y` (from `.zshrc`) leaves you in the folder you browsed to when you quit with `q`.

Install yazi and its preview helpers (fd, ripgrep, fzf and zoxide are already in step 2):

```bash
brew install yazi ffmpeg-full sevenzip jq poppler resvg imagemagick-full
```

```bash
brew link ffmpeg-full imagemagick-full -f --overwrite
```

Images preview in WezTerm out of the box. Neovim installs `yazi.nvim` on its next start; `:checkhealth yazi` checks the setup.

## Windows

Neovim reads its config from `%LOCALAPPDATA%\nvim` unless the `XDG_CONFIG_HOME` user environment variable points at `C:\Users\<you>\.config`. Link the repo's config into place with a directory junction:

```powershell
cmd /c mklink /J "$env:USERPROFILE\.config\nvim" "$env:USERPROFILE\Desktop\Work\dotfiles\nvim"
```

Claude Code reads `%USERPROFILE%\.claude\CLAUDE.md`. Point it at the repo's `AGENTS.md`:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude" | Out-Null
Set-Content -Encoding utf8 "$env:USERPROFILE\.claude\CLAUDE.md" '@~/Desktop/Work/dotfiles/claude/AGENTS.md'
```

WezTerm: install it, then link the config folder (WezTerm reads `%USERPROFILE%\.config\wezterm\wezterm.lua` on Windows too). It opens PowerShell and uses its bundled JetBrains Mono, so Hack Nerd Font is optional:

```powershell
winget install wez.wezterm
cmd /c mklink /J "$env:USERPROFILE\.config\wezterm" "$env:USERPROFILE\Desktop\Work\dotfiles\wezterm"
```

Herdr: file symlinks need Developer Mode (Settings → System → For developers) or an admin shell. Without it, copy the files, and copy again after pulling changes:

```powershell
$h = "$env:USERPROFILE\.config\herdr-app"; $d = "$env:USERPROFILE\Desktop\Work\dotfiles\herdr"
New-Item -ItemType Directory -Force "$h\themes" | Out-Null
Copy-Item "$d\keys.json" "$h\keys.json"; Copy-Item "$d\themes\iceberg.json" "$h\themes\iceberg.json"
```

Merge `herdr\settings.json` into `$h\settings.json` by hand, so machine-specific values like `zoom` stay.

Yazi: install it and its preview helpers, then point `YAZI_FILE_ONE` at Git for Windows' `file.exe` (yazi needs it to detect file types) and restart the terminal:

```powershell
winget install sxyazi.yazi Gyan.FFmpeg 7zip.7zip jqlang.jq oschwartz10612.Poppler ImageMagick.ImageMagick
[Environment]::SetEnvironmentVariable("YAZI_FILE_ONE", "C:\Program Files\Git\usr\bin\file.exe", "User")
```
