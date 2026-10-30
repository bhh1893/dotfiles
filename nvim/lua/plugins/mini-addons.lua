return {
  {
    'nvim-mini/mini.nvim',
    version = false,
    event = 'VeryLazy',
    config = function()
      require('mini.ai').setup()       -- extra a/i textobjects: args (a), calls (f), brackets (b), quotes (q)
      require('mini.align').setup()    -- ga / gA to align text interactively
      require('mini.comment').setup()  -- gc / gcc to toggle comments
      require('mini.pairs').setup()    -- auto-close brackets and quotes
      require('mini.move').setup()     -- Alt + hjkl to move lines / selections
      require('mini.surround').setup() -- sa / sd / sr to add, delete, replace surroundings
    end,
  },
}
