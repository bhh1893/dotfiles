return {
  {
    'nvim-mini/mini.nvim',
    version = false,
    lazy = false, -- load at startup so mini.starter can show on launch
    config = function()
      -- Editing
      require('mini.ai').setup()       -- extra a/i textobjects: args (a), calls (f), brackets (b), quotes (q)
      require('mini.align').setup()    -- ga / gA to align text interactively
      require('mini.comment').setup()  -- gc / gcc to toggle comments
      require('mini.pairs').setup()    -- auto-close brackets and quotes
      require('mini.move').setup()     -- Alt + hjkl to move lines / selections
      require('mini.surround').setup({ -- gsa / gsd / gsr to add, delete, replace surroundings
        -- On gs instead of s, which flash uses for jumping
        mappings = {
          add = 'gsa', delete = 'gsd', replace = 'gsr',
          find = 'gsf', find_left = 'gsF', highlight = 'gsh',
        },
      })
      require('mini.icons').setup()    -- file and language icons (used by render-markdown)
      require('mini.completion').setup() -- completion popup + signature help (LSP, buffer words)

      -- Tab / Shift-Tab move through the completion menu when it's open
      local function pum(key, fallback)
        return function() return vim.fn.pumvisible() == 1 and key or fallback end
      end
      vim.keymap.set('i', '<Tab>', pum('<C-n>', '<Tab>'), { expr = true, desc = 'Next completion' })
      vim.keymap.set('i', '<S-Tab>', pum('<C-p>', '<S-Tab>'), { expr = true, desc = 'Prev completion' })

      -- No completion popup while typing in Snacks pickers and prompts
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'snacks_picker_input', 'snacks_input' },
        callback = function() vim.b.minicompletion_disable = true end,
      })

      -- Workflow
      local misc = require('mini.misc')
      misc.setup()
      misc.setup_restore_cursor()      -- reopen files at the last cursor position
      vim.keymap.set('n', '<leader>z', misc.zoom, { desc = 'Zoom window' })

      local trailspace = require('mini.trailspace')
      trailspace.setup()               -- highlight trailing whitespace
      vim.keymap.set('n', '<leader>cw', trailspace.trim, { desc = 'Trim trailing whitespace' })

      -- Appearance
      require('mini.starter').setup()  -- start screen when nvim opens without a file
      require('mini.cursorword').setup() -- underline other uses of the word under the cursor
      require('mini.indentscope').setup({
        draw = { animation = require('mini.indentscope').gen_animation.none() },
      })                               -- line showing the current indent scope; ii / ai, [i / ]i

      -- No indent scope line in non-code buffers
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'help', 'lazy', 'mason', 'oil', 'ministarter', 'markdown' },
        callback = function() vim.b.miniindentscope_disable = true end,
      })

      -- Key hints: pause after a prefix key to see what can follow
      local miniclue = require('mini.clue')
      miniclue.setup({
        triggers = {
          { mode = 'n', keys = '<Leader>' }, { mode = 'x', keys = '<Leader>' },
          { mode = 'n', keys = 'g' },        { mode = 'x', keys = 'g' },
          { mode = 'n', keys = '[' },        { mode = 'n', keys = ']' },
          { mode = 'n', keys = "'" },        { mode = 'n', keys = '`' },
          { mode = 'n', keys = '"' },        { mode = 'x', keys = '"' },
          { mode = 'i', keys = '<C-r>' },    { mode = 'c', keys = '<C-r>' },
          { mode = 'n', keys = '<C-w>' },
          { mode = 'n', keys = 'z' },        { mode = 'x', keys = 'z' },
        },
        clues = {
          { mode = 'n', keys = '<Leader>g', desc = '+Git' },
          { mode = 'n', keys = '<Leader>c', desc = '+Code' },
          { mode = 'n', keys = 'gs', desc = '+Surround' },
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
        window = { delay = 300 },
      })
    end,
  },
}
