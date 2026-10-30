return {
  {
    'mason-org/mason.nvim', -- :Mason to install/update language servers and tools
    opts = {},
  },
  {
    'mason-org/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
      'neovim/nvim-lspconfig',  -- server configs for vim.lsp.enable
      'nvim-mini/mini.nvim',    -- mini.completion capabilities
    },
    opts = {
      -- Python: basedpyright (types, go-to, hover) + ruff (lint, quick fixes)
      -- Java: jdtls (needs Java 21+: brew install openjdk)
      ensure_installed = { 'basedpyright', 'ruff', 'jdtls' },
    },
    config = function(_, opts)
      vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
      vim.diagnostic.config({ virtual_text = true, severity_sort = true })
      require('mason-lspconfig').setup(opts) -- installs and enables the servers above
    end,
  },
}
