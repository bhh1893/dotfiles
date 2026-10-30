return {
  {
    "TaDaa/vimade",
    -- Dims inactive windows by recoloring them (no overlay windows), so
    -- floating windows like lazygit and pickers don't leave it stuck.
    event = "VeryLazy",
    opts = {
      recipe = { "default", { animate = false } },
      ncmode = "windows", -- dim every window that isn't focused
      fadelevel = 0.4,    -- 0-1, lower means darker inactive windows
    },
  }
}
