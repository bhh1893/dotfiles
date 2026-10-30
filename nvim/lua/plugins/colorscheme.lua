return {
  {
    'cocopon/iceberg.vim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = 'dark'
      vim.cmd('colorscheme iceberg')

      -- Let the terminal background show through on macOS, Windows and WSL
      local uname = vim.uv.os_uname()
      local transparent = uname.sysname == 'Darwin'
        or string.find(uname.sysname, 'Windows') ~= nil
        or string.find(uname.release, 'WSL') ~= nil
      if transparent then
        for _, group in ipairs({ 'Normal', 'NormalNC', 'SignColumn', 'EndOfBuffer' }) do
          vim.api.nvim_set_hl(0, group, { bg = 'NONE' })
        end
      end

      -- Make the dimmed directory path in the Snacks picker readable
      vim.api.nvim_set_hl(0, 'SnacksPickerDir', { fg = '#818596' })
    end,
  },
}
