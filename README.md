# bhh1893 setup
 
My setup in a single script
 
It installs and configures:
 
- zsh (and sets it as the default shell)
- oh-my-zsh, plus zsh-syntax-highlighting, zsh-autosuggestions and zsh-fzf-history-search
- the pure prompt
- fzf
- vim-plug, then runs `PlugInstall` (including a YouCompleteMe build)
- `~/.zshrc` and `~/.vimrc` (existing files are backed up to `*.bak.<timestamp>`)
- git setting: `git branch` prints directly instead of opening in `less`
Supports Debian/Ubuntu (apt), Fedora/RHEL (dnf), Arch (pacman) and macOS (Homebrew).
 
## Quick start: download and run in one command
 
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/bhh1893/my_setup_bhh/main/setup.sh)
```
 
### Alternatives
 
Pipe version (works fine if the machine already has passwordless sudo):
 
```bash
curl -fsSL https://raw.githubusercontent.com/bhh1893/my_setup_bhh/main/setup.sh | bash
```
 
If the machine has `wget` but not `curl`:
 
```bash
bash <(wget -qO- https://raw.githubusercontent.com/bhh1893/my_setup_bhh/main/setup.sh)
```
 
Clone and run (lets you read the script first):
 
```bash
git clone https://github.com/bhh1893/my_setup_bhh.git
cd my_setup_bhh
./setup.sh
```
 
## What the curl flags mean
 
| Flag | Meaning |
|------|---------|
| `-f` | Fail on HTTP errors (so a 404 page is never executed as a script) |
| `-s` | Silent: no progress bar |
| `-S` | Still show errors when silent |
| `-L` | Follow redirects |
