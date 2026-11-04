return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function map(lhs, rhs, desc, mode)
          vim.keymap.set(mode or 'n', lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Jump between hunks (falls back to built-in ]c/[c inside diff windows)
        map(']c', function()
          if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gs.nav_hunk('next') end
        end, 'Next hunk')
        map('[c', function()
          if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gs.nav_hunk('prev') end
        end, 'Prev hunk')

        map('<leader>gp', gs.preview_hunk, 'Preview hunk')
        map('<leader>ga', gs.stage_hunk, 'Stage/unstage hunk')
        map('<leader>gr', gs.reset_hunk, 'Reset hunk')
        map('<leader>gB', gs.blame_line, 'Blame line')

        -- ih textobject: vih selects a hunk, dih deletes it
        map('ih', gs.select_hunk, 'Select hunk', { 'o', 'x' })
      end,
    },
  },
  {
    'folke/snacks.nvim',
    keys = {
      { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazygit' },
      { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git status' },
      { '<leader>gl', function() Snacks.picker.git_log() end, desc = 'Git log' },
      { '<leader>gf', function() Snacks.picker.git_log_file() end, desc = 'Git log (file)' },
      { '<leader>gb', function() Snacks.picker.git_branches() end, desc = 'Git branches' },
    },
  },
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diff all changes' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File history' },
      { '<leader>gq', '<cmd>DiffviewClose<cr>', desc = 'Close diffview' },
    },
  },
}
