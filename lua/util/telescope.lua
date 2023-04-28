local M = {}

---@param opts table | function
local function parse_opts(opts)
  opts = "function" == type(opts) and opts() or opts
  vim.validate({ opts = { opts, "table" } })

  local theme = opts.theme and require("telescope.themes")["get_" .. opts.theme]
    or nil
  if nil == theme then
    vim.notify(
      string.format("Selected theme (%s) doesn't exists", opts.theme),
      vim.log.levels.WARN
    )
  end
  return theme and theme(opts) or opts
end

---@param fname string | function
---@param opts table | nil
function M.map_tele(fname, opts)
  return function()
    fname = "function" == type(fname) and fname() or fname

    -- custom function
    local custom = require("plugins.telescope.custom")[fname]
    if custom then
      custom(parse_opts(opts or {}))
      return
    end

    -- telescope extension
    ---@diagnostic disable-next-line: param-type-mismatch
    local i, _ = string.find(fname, "%.")
    if i then
      ---@diagnostic disable-next-line: param-type-mismatch
      local ext = string.sub(fname, 1, i - 1)
      ---@diagnostic disable-next-line: param-type-mismatch
      local func = string.sub(fname, i + 1)
      require("telescope").extensions[ext][func](parse_opts(opts or {}))
      return
    end

    -- builtin
    local builtin = require("telescope.builtin")[fname]
    if builtin then
      builtin(parse_opts(opts or {}))
      return
    end

    -- fallback
    vim.notify(
      string.format("(%s) is not callable by Telescope", fname),
      vim.log.levels.WARN
    )
  end
end

return M
