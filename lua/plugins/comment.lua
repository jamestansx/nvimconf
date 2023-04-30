return {
  "numToStr/Comment.nvim",
  event = "VeryLazy",
  version = false,
  opts = function()
    return {
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    }
  end,
}
