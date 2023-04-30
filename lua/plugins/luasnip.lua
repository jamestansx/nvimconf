return {
  "L3MON4D3/LuaSnip",
  version = false,
  lazy = true,
  dependencies = "rafamadriz/friendly-snippets",
  opts = function()
    local types = require("luasnip.util.types")
    local C = require("catppuccin.palettes").get_palette(vim.g.catppuccin_theme)
    vim.api.nvim_set_hl(0, "choiceNode", { fg = C.mauve })

    return {
      history = false,
      update_events = { "TextChanged", "TextChangedI", "InsertLeave" },
      region_check_events = { "CursorMoved", "TextChanged" },
      delete_check_events = "CursorHold",
      enable_autosnippets = true,
      store_selection_keys = "<Tab>",
      ext_opts = {
        [types.insertNode] = {
          active = {
            virt_text = { { "«", "choiceNode" } },
          },
        },
      },
    }
  end,
  config = function(_, opts)
    require("luasnip").setup(opts)
    require("luasnip.loaders.from_vscode").lazy_load()
  end,
}
