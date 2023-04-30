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

function M.is_empty(val, fallback)
  return vim.fn.empty(val) and fallback or val
end

return M
