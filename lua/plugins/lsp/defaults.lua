local M = {}

M.handlers = (function()
  local handlers = vim.lsp.handlers

  local publishDiagnostics = handlers["textDocument/publishDiagnostics"]
  publishDiagnostics = vim.lsp.with(publishDiagnostics, {
    signs = {
      severity_limit = "Error",
    },
    underline = {
      severity_limit = "Warning",
    },
    severity_sort = true,
    update_in_insert = true,
  })

  return handlers
end)()

M.on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  require("plugins.lsp.keymaps").on_attach(client, bufnr)

  if client.server_capabilities["documentSymbolProvider"] then
    require("nvim-navic").attach(client, bufnr)
  end
  require("nvim-navbuddy").attach(client, bufnr)
end

M.capabilities = (function()
  return vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    require("cmp_nvim_lsp").default_capabilities() or {}
  )
end)()

return M
