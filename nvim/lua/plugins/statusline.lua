return {
  'echasnovski/mini.statusline',
  version = '*', -- Use 'false' for main branch or '*' for latest stable release
  config = function()
    require('mini.statusline').setup({
      -- Optional configuration options go here
      use_icons = true,
    })
  end,
}

