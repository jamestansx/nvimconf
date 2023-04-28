local M = {}

M.lua_ls = {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      completion = { callSnippet = "Replace" },
      telementry = { enable = false },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
    },
  },
}

return M
