local M = {}

M.autocmd = vim.api.nvim_create_autocmd

---@param grp string
---@param opts table | nil
M.augroup = function(grp, opts)
  vim.api.nvim_create_augroup("jamestansx_" .. grp, opts or { clear = true })
end

---@param plugin string
function M.has(plugin)
  return require("lazy.core.config").plugins[plugin] ~= nil
end

---@param mode string | table
---@param lhs string
---@param rhs string
---@param opts table | nil
function M.keymap(mode, lhs, rhs, opts)
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
function M.keymaps(mode, tbl)
  vim.validate({
    table = { tbl, "table" },
  })

  if "string" == type(tbl[1]) then
    M.keymap(mode, unpack(tbl))
    return
  end

  for _, v in pairs(tbl) do
    M.keymap(mode, unpack(v))
  end
end

---@param workspace string | nil
function M.is_git_worktree(workspace)
  local git_cmd = "git rev-parse --is-inside-work-tree"

  if workspace then
    workspace = vim.fn.shellescape(vim.fn.expand(workspace))
    git_cmd = string.format("(cd %s && %s)", workspace, git_cmd)
  end

  vim.fn.system(git_cmd)
  return 0 == vim.v.shell_error
end

---@param workspace string | nil
function M.get_python_path(workspace)
  local util = require("lspconfig.util")
  local path = util.path

  local env_path = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
  if env_path then
    return path.join(env_path, "bin", "python")
  end

  workspace = workspace or vim.fn.getcwd()
  for _, pattern in ipairs({ "*", ".*" }) do
    local match = vim.fn.glob(path.join(workspace, pattern, "pyvenv.cfg"))
    if "" ~= match then
      return path.join(path.dirname(match), "bin", "python")
    end
  end

  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

-- https://github.com/LazyVim/LazyVim/blob/86ac9989ea15b7a69bb2bdf719a9a809db5ce526/lua/lazyvim/util/init.lua#L163
function M.lazy_notify()
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.loop.new_timer()
  local check = vim.loop.new_check()

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- put back the original notify if needed
    end
    vim.schedule(function()
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- wait till vim.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

return M
