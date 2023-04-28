local M = {}
local api = vim.api
local util = require("util")
local autocmd = util.autocmd
local augroup = util.augroup

function M.format(opts, bufnr)
  return function()
    local ft = vim.bo[bufnr or 0].filetype
    local have_nls = #require("null-ls.sources").get_available(
      ft,
      "NULL_LS_FORMATTING"
    ) > 0

    opts = vim.tbl_deep_extend("force", {
      filter = function(client)
        return have_nls and client.name == "null-ls" or client.name ~= "null-ls"
      end,
      bufnr = bufnr or nil,
    }, opts or {})

    vim.lsp.buf.format(opts)
  end
end

function M.on_attach(client, bufnr)
  LspFormatting = augroup("LspFormatting")
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = LspFormatting, buffer = bufnr })
    autocmd("BufWritePre", {
      desc = "Enable auto formatting",
      group = LspFormatting,
      buffer = bufnr,
      callback = M.format({ async = false }, bufnr),
    })
  end
end

return M
