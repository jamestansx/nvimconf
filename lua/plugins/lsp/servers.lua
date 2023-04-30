local M = {}

M.lua_ls = {
  settings = {
    Lua = {
      addonManager = { enable = false },
      codeLens = { enable = true },
      completion = { callSnippet = "Replace" },
      diagnostics = {
        globals = { "vim" },
      },
      runtime = { version = "LuaJIT" },
      telementry = { enable = false },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
    },
  },
}

return M
