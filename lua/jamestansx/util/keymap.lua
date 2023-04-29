local M = {}

---@param mode string | table
---@param lhs string
---@param rhs string
---@param opts table?
function M.map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys

  ---@cast keys LazyKeysHandler
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = false ~= opts.silent
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

---@param mode string | table
---@param tbl table
function M.maps(mode, tbl)
  vim.validate({
    table = { tbl, "table" },
  })

  if "string" == type(tbl[1]) then
    M.map(mode, unpack(tbl))
    return
  end

  for _, v in pairs(tbl) do
    M.map(mode, unpack(v))
  end
end

---@param opts table | function
local function tele_themes(opts)
  opts = "function" == type(opts) and opts() or opts
  vim.validate({ opts = { opts, "table" } })
  local theme = require("telescope.themes")["get_" .. (opts.theme or "")]

  return theme and theme(opts) or opts
end

---@param fname string | fun(tbl?:table):string
---@param opts table?
---@return function
function M.map_tele(fname, opts)
  return function()
    fname = "function" == type(fname) and fname() or fname
    vim.validate({ fname = { fname, "string" } })

    -- custom function
    local custom = require("plugins.telescope.custom")[fname]
    if custom then
      custom(tele_themes(opts or {}))
      return
    end

    -- telescope extension
    local i, _ = string.find(fname --[[@as string]], "%.")
    if i then
      local ext = string.format(fname --[[@as string]], 1, i - 1)
      local func = string.format(fname --[[@as string]], i + 1)
      require("telescope").extensions[ext][func](tele_themes(opts or {}))
      return
    end

    -- builtin
    local builtin = require("telescope.builtin")[fname]
    if builtin then
      builtin(tele_themes(opts or {}))
      return
    end
  end
end

return M
