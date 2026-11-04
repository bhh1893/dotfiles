return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    opts = {
      formatters_by_ft = {
        python = { 'ruff_organize_imports', 'ruff_format' },
        -- Java has no entry, so it falls back to jdtls formatting
      },
      default_format_opts = { lsp_format = 'fallback' },
      format_on_save = { timeout_ms = 1000, lsp_format = 'fallback' },
    },
    keys = {
      { '<leader>cf', function() require('conform').format({ async = true }) end, desc = 'Format buffer' },
    },
  },
}
