local flavor = "mocha"
vim.g.__catppuccin_flavor = flavor

return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    flavor = flavor,
    transparent_background = true,
    term_colors = true,
    highlight_overrides = {
      all = function()
        local U = require("catppuccin.utils.colors")
        local C = require("catppuccin.palettes").get_palette(flavor)
        return {
          CursorLine = { bg = U.darken(C.surface0, 0.64, C.base) },
          TreesitterContext = { link = "NormalFloat" },
          TreesitterContextLineNumber = { link = "NormalFloat" },
          TelescopePrompt = { link = "TelescopePromptNormal" },
          HarpoonWindow = { fg = C.text, bg = C.base },
          HarpoonBorder = { fg = C.blue, bg = C.base },
          DapUIFloatBorder = { fg = C.sky, bg = C.base },
          DapUIFloatNormal = { link = "NormalFloat" },
          NvimTreePopup = { link = "NormalFloat" },
        }
      end,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
