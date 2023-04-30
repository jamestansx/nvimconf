local M = {
  keymap = require("jamestansx.util.keymap"),
  path = require("jamestansx.util.path"),
  lsp = require("jamestansx.util.lsp"),
}

local api = vim.api
local fn = vim.fn

---@param name string
---@param opts table?
function M.augroup(name, opts)
  api.nvim_create_augroup("jamestansx_" .. name, opts or { clear = true })
end

return M
