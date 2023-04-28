local M = {}

function M.diagnostics_goto(next, severity, float)
  local func = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    func({ severity = severity, float = float })
  end
end

function M.check_nls_sources(provider, bufnr)
  local map = {
    documentRangeFormatting = "NULL_LS_RANGE_FORMATTING",
    documentFormatting = "NULL_LS_FORMATTING",
    codeAction = "NULL_LS_CODE_ACTION",
  }

  return map[provider]
    and #require("null-ls.sources").get_available(
        vim.bo[bufnr].filetype,
        map[provider]
      )
      > 0
end

return M
