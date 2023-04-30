return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  init = function()
    vim.notify = require("notify")
  end,
  opts = {
    timeout = 2000,
    fps = 60,
    render = "compact",
    stages = "static",
    background_color = "#000000",
    max_height = function()
      return math.floor(vim.o.lines * 0.6)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.6)
    end,
    on_open = function(win)
      vim.api.nvim_win_set_option(win, "winblend", 0)
    end,
  },
}
