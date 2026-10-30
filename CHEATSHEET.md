# Neovim cheat sheet

Leader is **Space**. Lost? Press Space (or `g`, `[`, `]`, `z`) and wait: mini.clue shows what comes next.

Open this file in Neovim to see it rendered (`<leader>m` toggles the raw view).

## Windows

| Keys | Action |
|---|---|
| `<leader>h` `j` `k` `l` | Move to the window left / below / above / right |
| `<leader>v` / `<leader>s` | Split vertically / horizontally |
| `<leader>q` | Close the window |
| Ctrl+h `j` `k` `l` | Resize the window (hold to keep resizing) |
| `<leader>z` | Zoom the window full screen and back |

## Finding files and text

| Keys | Action |
|---|---|
| `<leader>f` | Find files by name (fuzzy: `gitl` finds `git.lua`) |
| `<leader>/` | Search text inside files |
| `<leader>b` | Open buffers |
| `<leader>e` | oil: edit the directory like text |
| `<leader>t` | File tree sidebar |

Searches cover the folder you started `nvim` in (`:pwd`) and everything below it, skipping hidden and git-ignored files.

**Inside a picker:** type to filter · Ctrl+j / Ctrl+k move · Enter open · Ctrl+v vertical split · Ctrl+s horizontal split · Alt+h hidden files · Alt+i ignored files · Esc close

**oil:** Enter open · `-` parent folder · edit names, `dd` to delete, cut and paste to move · `:w` applies changes · Ctrl+p preview

**File tree:** `l` / Enter open · `h` close folder · Backspace up a level · `a` add (end with `/` for a folder) · `r` rename · `d` delete · `c` copy · `m` move · `/` filter · `?` all keys

## Moving around

| Keys | Action |
|---|---|
| `s` + chars + label | Flash: type part of what you see, then its label to jump there |
| `S` + label | Select a Treesitter node (function, block, …) |
| `f` / `F` + char | Jump to the next / previous char, across lines. Press `f` again to repeat |
| `t` / `T` + char | Same, stopping just before / after it |
| `r` after an operator | Remote: `yr` + label + `iw` copies a word elsewhere without moving |
| `[i` / `]i` | Start / end of the current indent block |
| `]c` / `[c` | Next / previous git change |
| `]d` / `[d` | Next / previous error or warning |

## Editing

**Text objects** (use after `d` delete, `c` change, `y` copy, `v` select, `gsa` surround):

| Object | Means |
|---|---|
| `iw` / `aw` | Word |
| `ia` / `aa` | Function argument (`aa` includes the comma) |
| `if` / `af` | Function call |
| `ib` / `ab` | Nearest bracket of any kind |
| `iq` / `aq` | Nearest quote of any kind |
| `ii` / `ai` | Indent block (good for Python) |
| `it` / `at` | HTML tag |
| `ih` | Git change (hunk) |

Add `n` / `l` for the next / last one: `cin"` changes inside the next quotes.

| Keys | Action |
|---|---|
| `gsa` + motion + char | Surround: `gsaiw"` wraps a word in quotes |
| `gsd` + char | Delete a surrounding: `gsd"` |
| `gsr` + old + new | Replace a surrounding: `gsr)]` |
| `gcc` / `gc` + motion | Toggle comment |
| `ga` + char | Align on a character (select lines first) |
| Alt+h `j` `k` `l` | Move the line or selection |
| Tab / Shift+Tab, Ctrl+y | Next / previous completion, accept |
| Ctrl+a | Select all |
| `<leader>cw` | Trim trailing whitespace |

Brackets and quotes close themselves as you type. Pasting over a selection keeps your clipboard.

## Code (LSP)

| Keys | Action |
|---|---|
| `gd` | Go to definition |
| `K` | Docs for the thing under the cursor |
| `grn` | Rename everywhere |
| `gra` | Code action (quick fixes) |
| `grr` | References |
| `gri` | Implementations |
| `gO` | Symbols in this file |
| Ctrl+w `d` | Show the error under the cursor |
| `<leader>cf` | Format now (saving formats too) |

Python: basedpyright + ruff. Java: jdtls. Treesitter, basedpyright and Java need the macOS setup in the README; on Windows only ruff runs.

## Git in Neovim

| Keys | Action |
|---|---|
| `<leader>gg` | lazygit in a floating window |
| `<leader>gp` | Preview the change under the cursor |
| `<leader>ga` | Stage / unstage that change |
| `<leader>gr` | Reset (undo) that change |
| `<leader>gB` | Blame the current line |
| `<leader>gs` | Changed files |
| `<leader>gl` / `<leader>gf` | Repo log / this file's log |
| `<leader>gb` | Branches |
| `<leader>gd` | Diffview of all changes (`<leader>gq` closes) |
| `<leader>gh` | This file's history |

## lazygit

`1`–`5` panels · `?` keys for this panel · `q` quit · `z` undo

| Panel | Keys |
|---|---|
| Files (`2`) | Space stage · `a` stage all · Enter stage parts of a file · `c` commit · `A` amend · `e` open in Neovim · `d` discard · `s` stash |
| Branches (`3`) | `n` new · Space switch · `M` merge · `r` rebase · `d` delete |
| Commits (`4`) | `r` reword · `s` squash · `f` fixup · `d` drop · Ctrl+j / Ctrl+k move · `C` then `V` cherry-pick · `g` reset |
| Anywhere | `P` push · `p` pull · `f` fetch · `@` git command log |

## Git in the terminal

| Command | Action |
|---|---|
| `git st` | Short status |
| `git lg` | History graph |
| `git add -p` | Stage piece by piece |
| `git rebase -i HEAD~3` | Tidy recent commits (opens Neovim) |
| `git difftool` / `git mergetool` | Diffs and conflicts in Neovim |
| `git reflog` | Find "lost" commits |

Diffs show through delta.

## Other

| Keys / command | Action |
|---|---|
| `<leader>m` | Toggle markdown rendering |
| `nvim` with no file | Start screen with recent files |
| `:Lazy` / `:Lazy update` / `:Lazy restore` | Plugins: status / update / back to `lazy-lock.json` |
| `:Mason` | Language servers and tools |
| `:ConformInfo` | Which formatter runs for this file |
| `:checkhealth` | Diagnose problems |

Inactive windows dim, the current indent block has a guide line, other uses of the word under the cursor are underlined, and files reopen where you left off.

## Practice plan

1. `cd` into a project, `nvim`, then `<leader>f` and `<leader>/` to get around.
2. Use `s` + label for every jump for five minutes.
3. Edit a Python file: try `cia`, `daa`, `gsaiw"`, `dii`, `gcc`, then save to see formatting.
4. Make changes, then `]c`, `<leader>gp`, `<leader>ga`, and commit with `<leader>gg`.
5. Pause after `<leader>` and `g` and read what mini.clue offers.
