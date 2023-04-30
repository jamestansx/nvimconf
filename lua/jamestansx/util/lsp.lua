local M = {}

---@type table
M.nls_mapping = {
  documentRangeFormatting = "NULL_LS_RANGE_FORMATTING",
  documentFormatting = "NULL_LS_FORMATTING",
  codeAction = "NULL_LS_CODE_ACTION",
}

---@param bufnr integer
---@param source string
---@return boolean
local function have_nls(bufnr, source)
  return #require("null-ls.sources").get_available(
    vim.bo[bufnr].filetype,
    source
  ) > 0
end

---@param bufnr integer
---@param provider string
---@return boolean
function M.check_nls_sources(bufnr, provider)
  return M.nls_mapping[provider] and have_nls(bufnr, M.nls_mapping[provider])
end

function M.format(opts)
  return function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    opts = vim.tbl_deep_extend("force", {
      filter = function(client)
        local ok = have_nls(bufnr, "NULL_LS_FORMATTING")
          and have_nls(bufnr, "NULL_LS_RANGE_FORMATTING")

        return ok and client.name == "null-ls" or client.name ~= "null-ls"
      end,
      bufnr = bufnr,
    }, opts or {})

    vim.lsp.buf.format(opts)
  end
end

-- TODO: make it togglable
function M.autoformat(client, bufnr)
  if
    client.config
    and client.config.capabilities
    and client.config.capabilities.documentFormattingProvider == false
  then
    return
  end

  local augroup = require("jamestansx.util").augroup
  LspFormatting = augroup("LspFormatting")
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = LspFormatting, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      desc = "Enable auto formatting",
      group = LspFormatting,
      buffer = bufnr,
      callback = M.format({ async = false }),
    })
  end
end

---@alias modes "next" | "prev"
---@alias severity
---| "HINT"
---| "INFO"
---| "WARN"
---| "ERROR"
---@param mode modes
---@param severity severity?
---@param opts table?
function M.diagnostic_goto(mode, severity, opts)
  local go = vim.diagnostic["goto_" .. mode]
  severity = severity and vim.diagnostic.severity[severity] or nil
  opts = vim.tbl_deep_extend("force", { severity = severity }, opts)

  return function()
    go(opts)
  end
end

return M
