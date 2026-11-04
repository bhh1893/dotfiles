return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    dependencies = { 'nvim-mini/mini.nvim' }, -- for mini.icons
    opts = {},
    keys = {
      { '<leader>m', '<cmd>RenderMarkdown toggle<cr>', desc = 'Toggle markdown rendering' },
    },
  },
}
