return {
  {
    "echasnovski/mini.ai",
    version = "*",
    opts = function()
      local ai = require("mini.ai")
      local ts_spec = ai.gen_spec.treesitter

      return {
        custom_textobjects = {
          o = ts_spec({
            a = { "@conditional.outer", "@loop.outer" },
            i = { "@conditional.inner", "@loop.inner" },
          }),
          c = ts_spec({ a = "@class.outer", i = "@class.inner" }),
          f = ts_spec({ a = "@function.outer", i = "@function.inner" }),
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
    end
  },
}
