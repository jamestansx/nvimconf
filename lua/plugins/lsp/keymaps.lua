local M = {}
M._keymaps = nil
local util = require("jamestansx.util")

function M.get()
  if not M._keymaps then
    local buf = vim.lsp.buf
    local lsp = util.lsp
    local t = util.keymap.map_tele
    M._keymaps = {
      {
        "gd",
        t("lsp_definitions"),
        desc = "[G]oto [D]efinition",
        has = "definition",
      },
      {
        "gD",
        buf.declaration,
        desc = "[G]oto [D]eclaration",
        has = "declaration",
      },
      { "gT", t("lsp_type_definitions"), desc = "[G]oto [T]ype definition" },
      {
        "gr",
        t("lsp_references", {
          layout_strategy = "vertical",
          layout_config = {
            prompt_position = "top",
          },
          sorting_strategy = "ascending",
          ignore_filename = false,
        }),
        desc = "[G]oto [R]eference",
      },
      {
        "gI",
        t("lsp_implementations", {
          layout_strategy = "vertical",
          layout_config = {
            prompt_position = "top",
          },
          sorting_strategy = "ascending",
          ignore_filename = false,
        }),
        desc = "[G]oto [I]mplementation",
        has = "implementation",
      },
      {
        "gs",
        buf.signature_help,
        desc = "[G]oto [S]ignature help",
        has = "signatureHelp",
      },
      { "K", buf.hover, desc = "Hover Docs" },
      {
        "<leader>ds",
        t("lsp_document_symbols"),
        desc = "[D]ocument [S]ymbol",
        has = "documentSymbol",
      },
      {
        "<leader>ws",
        t("lsp_dynamic_workspace_symbols"),
        desc = "[W]orkspace [S]ymbol",
        has = "workspaceSymbol",
      },

      {
        "<leader>ca",
        buf.code_action,
        desc = "[C]ode [A]ction",
        has = "codeAction",
      },
      { "<leader>cr", buf.rename, desc = "[C]ode [R]ename", has = "rename" },
      {
        "<leader>cf",
        lsp.format({ async = false }),
        desc = "[C]ode [F]ormatting",
        has = "documentFormatting",
      },
      {
        "<leader>cf",
        lsp.format({ async = false }),
        desc = "[C]ode [F]ormatting",
        mode = "v",
        has = "documentRangeFormatting",
      },
      {
        "]e",
        lsp.diagnostic_goto("next", "ERROR", { float = true }),
        desc = "Next Error",
      },
      {
        "[e",
        lsp.diagnostic_goto("prev", "ERROR", { float = true }),
        desc = "Prev Error",
      },
      {
        "]d",
        lsp.diagnostic_goto("next", nil, { float = true }),
        desc = "Next Diagnostic",
      },
      {
        "[d",
        lsp.diagnostic_goto("prev", nil, { float = true }),
        desc = "Prev Diagnostic",
      },
    }
  end

  return M._keymaps
end

function M.on_attach(client, bufnr)
  local Keys = require("lazy.core.handler.keys")
  local keymaps = {}

  for _, value in pairs(M.get()) do
    local keys = Keys.parse(value)
    if keys[2] == vim.NIL or keys[2] == false then
      keymaps[keys.id] = nil
    else
      keymaps[keys.id] = keys
    end
  end

  for _, key in pairs(keymaps) do
    if
      not key.has
      or client.server_capabilities[key.has .. "Provider"]
      or util.lsp.check_nls_sources(bufnr, key.has)
    then
      local opts = Keys.opts(key)
      opts.has = nil
      opts.silent = true
      opts.buffer = bufnr
      util.keymap.map(key.mode or "n", key[1], key[2], opts)
    end
  end
end

return M
