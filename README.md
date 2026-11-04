# bhh1893 setup

Dotfiles for macOS and Ubuntu, linked into place with [GNU Stow](https://www.gnu.org/software/stow/). `nvim/` is the source of truth for the Neovim config. For keymaps and how to use everything, see [CHEATSHEET.md](CHEATSHEET.md).

## Prerequisites

- `git`
- macOS only: Apple's developer tools (`xcode-select --install`) and [Homebrew](https://brew.sh)
- Ubuntu only: a user with passwordless `sudo`

## Install

```bash
git clone https://github.com/bhh1893/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` works out of any checkout location. It installs the packages (`apt` on Ubuntu, `brew` on macOS), links the configs with stow, sets zsh as the login shell, fetches the bat theme and fzf-git, and restores the agent skills in `skills/.skill-lock.json` (needs Node.js; on Ubuntu install it first, or set `DOTFILES_SKIP_SKILLS=1` to skip that step).

It never prompts, exits non-zero on failure, and is safe to re-run: a second run changes nothing. It prints `DOTFILES_CHANGED` when a run changed something, which Ansible uses for `changed_when`. If a real file is in the way (Ubuntu ships a `~/.zshrc`), it is moved to `<file>.pre-dotfiles` before linking; stow never runs with `--adopt`.

The Ubuntu install is for a headless dev VM: it skips WezTerm and Herdr.

## Layout

Every top-level folder is a stow package that mirrors `$HOME`: `starship/.config/starship.toml` is linked to `~/.config/starship.toml`, `zsh/.zshrc` to `~/.zshrc`. Edit the file in the repo or through the link; they are the same file.

Config that differs per OS goes in `<tool>/<tool>-<os>/` (`os` is `linux`, `mac` or `windows`), with the shared files in `<tool>/<tool>-common/`. Herdr is the first case:

```
herdr/
  herdr-common/.config/herdr/   settings.json, themes/
  herdr-mac/.config/herdr/      config.toml
  herdr-windows/.config/herdr/  config.toml
```

Stow them by hand with:

```bash
stow -d ~/dotfiles -t "$HOME" zsh                          # top-level package
stow -d ~/dotfiles/herdr -t "$HOME" herdr-common herdr-mac  # nested packages
```

### Adding a tool

1. Create `<tool>/` and put the files where they belong under `$HOME`, for example `<tool>/.config/<tool>/config.toml`. If the config differs per OS, use `<tool>/<tool>-common/` and `<tool>/<tool>-<os>/` instead.
2. Add it to `os_stow` in `install/linux.sh` and/or `install/mac.sh`: `stow_top <tool>`, or `stow_nested <tool>` for the per-OS layout.
3. Add its packages to `APT_PACKAGES` (`install/linux.sh`) and `BREW_FORMULAE` / `BREW_CASKS` (`install/mac.sh`), and a row to the table below.
4. Add a `.stow-local-ignore` inside a package folder if it holds files that must not be linked.

## Tools

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

On macOS `install.sh` also installs `tree-sitter-cli`, `python`, `openjdk` (Treesitter parsers, Python and Java language servers), `node` (for the agent skills), `gh`, the Hack Nerd Font, WezTerm, Herdr and Yazi with its preview helpers. On Ubuntu `fd` and `bat` are installed as `fdfind` and `batcat`; the script links them as `fd` and `bat` in `~/.local/bin`.

## Notes per tool

**Neovim.** Open `nvim`. lazy.nvim installs every plugin on first launch (versions pinned in `lazy-lock.json`); restart Neovim once it finishes. Treesitter parsers build in the background (needs `tree-sitter-cli`), and Mason installs the language servers the first time you open a file (`:Mason` shows progress).

**Shell.** `zsh/.zshrc` sets up history, completion, autosuggestions, syntax highlighting, fzf (with fd, fzf-git and bat/eza previews), bat, eza and the starship prompt. The starship config shows the path from `~`, git branch, time on the right and `>` on the next line. The `.zshrc` adds short aliases (`cl`, `clc`, `clr`, ...) for Claude Code; see the cheat sheet.

**tmux.** Prefix Ctrl+Space, Iceberg colors. `tmux-sessionizer` is linked into `~/.local/bin` (prefix f: pick a project folder, switch to its session). Start tmux in the folder that holds your projects; prefix f then lists that folder and every project in it:

```bash
cd ~/code && tmux
```

**lazygit.** `e` opens files in Neovim.

**WezTerm.** `wezterm/.config/wezterm/wezterm.lua` sets Iceberg colors, Hack Nerd Font, both Option keys as Alt, no title bar and no tab bar (tmux does tabs). WezTerm reloads it on save.

**Herdr.** A terminal workspace manager for coding agents, with a prefix key like tmux: workspaces, tabs and panes. Use it or tmux per project; tmux stays set up. The config is TOML: Ctrl+Space prefix with tmux-style keys and Iceberg colors. After editing, apply it with `herdr server reload-config` (a few settings need a restart).

**Yazi.** Terminal file manager with previews for images, video, PDFs and archives. Start it with `y` (from `.zshrc`): quitting with `q` leaves you in the folder you browsed to. It isn't wired into Neovim: Neovim's built-in terminal can't show images, so previews only work in yazi run straight in WezTerm. Images preview in WezTerm out of the box. `ya env` shows which image method yazi picked; `Chafa` there means the terminal isn't passing images through.

**Claude Code.** Not installed by `install.sh`:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

`claude/.claude/CLAUDE.md` holds my personal instructions for coding agents and `claude/.claude/settings.json` my settings; both are linked into `~/.claude`, so every session loads them and edits in the repo apply straight away. Agent skills restore into `~/.agents/skills`, linked into `~/.claude/skills`.

## Terminal settings (macOS)

Using WezTerm? Its config already sets the font, Option as Alt and Iceberg colors; only the Ctrl+Space step below still applies.

- **Font:** set the terminal font to **Hack Nerd Font**, or icons show up as boxes.
- **Option as Alt:** needed for Alt keys (mini.move in Neovim, fzf's Alt+C).
  - iTerm2: Settings → Profiles → Keys → Left Option key = **Esc+**
  - Ghostty: `macos-option-as-alt = true`
  - kitty: `macos_option_as_alt yes`
  - Terminal.app: Settings → Profiles → Keyboard → **Use Option as Meta key**
- **Ctrl+Space for tmux:** macOS uses Ctrl+Space to switch input sources. Turn it off in System Settings → Keyboard → Keyboard Shortcuts → Input Sources, or tmux never sees it.
- **Colors (optional):** pick the **Iceberg** (dark) color scheme in your terminal so the shell matches Neovim, fzf and tmux. It's in [iTerm2-Color-Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes), which Ghostty includes.

## Git

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

## SSH key for GitHub

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

## Windows

`install.sh` does not cover Windows. If `~/.claude/CLAUDE.md` on Windows imports `claude/AGENTS.md`, that file moved. Change the import to:

```
@~/Desktop/Work/dotfiles/claude/.claude/CLAUDE.md
```

The Windows Herdr config is `herdr/herdr-windows/.config/herdr/config.toml`, formerly `herdr/powershell_keys.json`.
