local M = {}
local handlers = vim.lsp.handlers

local publishDiagnostics = handlers["textDocument/publishDiagnostics"]
handlers["textDocument/publishDiagnostics"] = vim.lsp.with(publishDiagnostics, {
  signs = {
    severity_limit = "Error",
  },
  underline = {
    severity_limit = "Warning",
  },
  virtual_text = true,
  severity_sort = true,
  update_in_insert = true,
})

return M
