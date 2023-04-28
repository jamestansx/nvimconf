local M = {}

function M.on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  require("plugins.lsp.keymaps").on_attach(client, bufnr)

  if client.server_capabilities["documentSymbolProvider"] then
    require("nvim-navic").attach(client, bufnr)
  end

  require("nvim-navbuddy").attach(client, bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local exist, cmp = pcall(require, "cmp_nvim_lsp")
M.capabilities = vim.tbl_deep_extend(
  "force",
  capabilities,
  exist and cmp.default_capabilities() or {}
)

return M
