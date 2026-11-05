return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    -- needs the markdown parser; skip quietly until treesitter has built it
    cond = function() return #vim.api.nvim_get_runtime_file('parser/markdown.*', false) > 0 end,
    dependencies = { 'nvim-mini/mini.nvim' }, -- for mini.icons
    opts = {},
    keys = {
      { '<leader>m', '<cmd>RenderMarkdown toggle<cr>', desc = 'Toggle markdown rendering' },
    },
  },
}
