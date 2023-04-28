local M = {}

M._keymaps = nil

function M.get()
  if not M._keymaps then
    local buf = vim.lsp.buf
    local format = require("plugins.lsp.format")
    local t = require("util.telesope").map_tele
    local l = require("util.lsp")
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
        t("lsp_references"),
        desc = "[G]oto [R]eference",
      },
      {
        "gI",
        t("lsp_implementations"),
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
      {
        "<leader>cr",
        buf.rename,
        desc = "[C]ode [R]ename",
        has = "rename",
      },
      {
        "<leader>cf",
        format.format({ async = false }),
        desc = "[C]ode [F]ormatting",
        has = "documentFormatting",
      },
      {
        "<leader>cf",
        buf.format,
        desc = "[C]ode [F]ormatting",
        mode = "v",
        has = "documentRangeFormatting",
      },
      {
        "]d",
        l.diagnostics_goto(true),
        desc = "Next diagnostic",
      },
      {
        "[d",
        l.diagnostics_goto(false),
        desc = "Prev diagnostic",
      },
      {
        "]e",
        l.diagnostics_goto(true, "ERROR"),
        desc = "Next error",
      },
      {
        "[e",
        l.diagnostics_goto(false, "ERROR"),
        desc = "Prev error",
      },
      {
        "]w",
        l.diagnostics_goto(true, "WARN"),
        desc = "Next warning",
      },
      {
        "[w",
        l.diagnostics_goto(false, "WARN"),
        desc = "Prev warning",
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
      or require("util.lsp").check_nls_sources(key.has, bufnr)
    then
      local opts = Keys.opts(key)
      opts.has = nil
      opts.silent = true
      opts.buffer = bufnr
      vim.keymap.set(key.mode or "n", key[1], key[2], opts)
    end
  end
end

return M
