return {
  {
    'stevearc/oil.nvim',
    lazy = false, -- load at startup so `nvim <dir>` opens oil instead of netrw
    opts = { default_file_explorer = true, view_options = { show_hidden = true } },
    keys = { { '<leader>e', '<cmd>Oil<cr>', desc = 'File Browser' } },
  },
  {
    'mikavilpas/yazi.nvim', -- yazi in a float, mainly for image/PDF previews
    version = '*',
    dependencies = { { 'nvim-lua/plenary.nvim', lazy = true } },
    opts = { open_for_directories = false }, -- oil stays the handler for `nvim <dir>`
    keys = {
      { '<leader>y', '<cmd>Yazi<cr>', mode = { 'n', 'v' }, desc = 'Yazi (current file)' },
      { '<leader>Y', '<cmd>Yazi cwd<cr>', desc = 'Yazi (project root)' },
    },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = {
        enabled = true,
        sources = { explorer = { hidden = true } }, -- show dotfiles in the tree (zsh/ only holds .zshrc)
      },
      notifier = { enabled = true },
      input = { enabled = true },
      explorer = { enabled = true, replace_netrw = false }, -- sidebar tree; oil stays the default for `nvim <dir>`
    },
    keys = {
      { '<leader>t', function() Snacks.explorer() end, desc = 'File Tree' },
      { '<leader>f', function() Snacks.picker.files() end, desc = 'Find Files' },
      { '<leader>/', function() Snacks.picker.grep() end,  desc = 'Search Text' },
      { '<leader>b', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    },
  },
}
