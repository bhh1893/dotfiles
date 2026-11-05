return {
  {
    'stevearc/oil.nvim',
    lazy = false, -- load at startup so `nvim <dir>` opens oil instead of netrw
    opts = { default_file_explorer = true, view_options = { show_hidden = true } },
    keys = { { '<leader>e', '<cmd>Oil<cr>', desc = 'File Browser' } },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    init = function()
      -- don't dim ignored/hidden paths in pickers; re-apply after colorscheme changes
      local function undim()
        for _, g in ipairs { 'PathIgnored', 'PathHidden', 'GitStatusIgnored' } do
          vim.api.nvim_set_hl(0, 'SnacksPicker' .. g, { link = 'Normal' })
        end
      end
      undim()
      vim.api.nvim_create_autocmd('ColorScheme', { callback = undim })
    end,
    opts = {
      picker = {
        enabled = true,
        main = { current = true }, -- open picks in the window you were in, not the first one
        sources = {
          explorer = { hidden  = true },          -- show dotfiles in the tree (zsh/ only holds .zshrc) },
          files    = { confirm = 'edit_vsplit' }, -- <cr> opens in a vertical split
          grep     = { confirm = 'edit_vsplit' },
        },
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
