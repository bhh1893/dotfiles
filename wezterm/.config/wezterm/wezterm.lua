-- ~/.config/wezterm/wezterm.lua
-- Linked into place by install.sh (GNU Stow)
-- Written for macOS; on Windows it falls back to a bundled font and PowerShell.

local wezterm = require('wezterm')
local config = wezterm.config_builder()

local is_mac = wezterm.target_triple:find('darwin') ~= nil
local is_windows = wezterm.target_triple:find('windows') ~= nil

-- ---- Look -----

config.color_scheme = 'iceberg-dark' -- matches Neovim, tmux, fzf and starship
-- Windows: JetBrainsMono NF (winget DEVCOM.JetBrainsMonoNerdFont). Plain JetBrains Mono has no icons.
config.font = is_mac and wezterm.font('Hack Nerd Font') or wezterm.font('JetBrainsMono NF')
config.font_size = is_mac and 14 or 11
config.window_padding = { left = 8, right = 8, top = 8, bottom = 4 }

-- tmux handles tabs and splits; WezTerm's tab bar only shows if you open a second tab
config.hide_tab_bar_if_only_one_tab = true
config.audible_bell = 'Disabled'

-- ---- Keys -----

-- Shift+Up / Shift+Down scroll the scrollback one line (Shift+PageUp/PageDown: a page)
config.keys = {
  { key = 'UpArrow', mods = 'SHIFT', action = wezterm.action.ScrollByLine(-1) },
  { key = 'DownArrow', mods = 'SHIFT', action = wezterm.action.ScrollByLine(1) },
}

-- ---- macOS -----

if is_mac then
  config.window_decorations = 'RESIZE' -- no title bar; tmux's status bar is enough
  -- Both Option keys send Alt (fzf Alt+c, mini.move); no é, ü, … from Option
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = false
end

-- ---- Windows -----

if is_windows then
  config.default_prog = { 'powershell.exe', '-NoLogo' }
  -- Git Bash instead: { 'C:\\Program Files\\Git\\bin\\bash.exe', '-l', '-i' }
end

return config
