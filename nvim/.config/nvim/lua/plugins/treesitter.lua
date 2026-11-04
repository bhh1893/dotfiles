return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local parsers = {
        'python', 'java', 'lua', 'vim', 'vimdoc', 'query',
        'markdown', 'markdown_inline', 'bash', 'json', 'yaml', 'toml',
      }
      -- Building parsers needs the tree-sitter CLI and a C compiler
      -- (macOS: brew install tree-sitter-cli; Xcode CLT provides clang)
      if vim.fn.executable('tree-sitter') == 1 then
        require('nvim-treesitter').install(parsers)
      end

      -- Treesitter highlighting and indent for any filetype with a parser
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
