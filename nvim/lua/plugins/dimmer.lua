return {
  {
    "sunjon/shade.nvim",
    -- Optional: You can trigger it on a specific event like WinNew or VimEnter 
    -- if you don't want it to load immediately on startup.
    event = "VeryLazy", 
    config = function()
      require("shade").setup({
        overlay_opacity = 35, -- 1-100, higher means darker inactive windows
        opacity_step = 1,     -- Step size when adjusting brightness
        keys = {
          brightness_up    = "<C-Up>",   -- Ctrl + Up Arrow
          brightness_down  = "<C-Down>", -- Ctrl + Down Arrow
        },
      })
    end,
  }
}
