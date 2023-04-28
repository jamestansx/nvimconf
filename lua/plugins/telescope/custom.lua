local M = {}

function M.grep_string(opts)
  vim.ui.input({ prompt = "Grep > " }, function(input)
    if input then
      local o = "" ~= input and { search = input } or {}
      opts = vim.tbl_deep_extend("force", o, opts or {})
      require("telescope.builtin").grep_string(opts)
    end
  end)
end

return M
