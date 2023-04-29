local M = {}

local fn = vim.fn

---@param workspace string?
function M.is_git_worktree(workspace)
  local git_cmd = "git rev-parse --is-inside-work-tree"

  if workspace then
    workspace = vim.fn.fnamemodify(vim.fn.expand(workspace), ":p:h")
    workspace = vim.fn.shellescape(workspace)
    git_cmd = string.format("(cd %s && %s)", workspace, git_cmd)
  end

  fn.system(git_cmd)
  return 0 == vim.v.shell_error
end

---@return string?
local function traverse_child(parent, marker, filematch)
  local lsp_util = require("lspconfig.util")
  local path = lsp_util.path

  for _, p in ipairs(marker) do
    for _, m in
      ipairs(
        vim.fn.glob(path.join(path.escape_wildcards(parent), p, filematch))
      )
    do
      if path.exists(m) then
        return m
      end
    end
  end
end

-- return python executable path based on:
-- * environment variable
-- * scan for pattern (pyvenv.cfg) by traversing directory downward from
--    * the current directory (not in git worktree)
--    * the git root directory
-- * scan for pattern (venv, .venv) by traversing directory upward from
--    * the current directory (not in git worktree)
-- * fallback: system executable
---@param workspace string?
---@param opts table?
function M.get_python_path(workspace, opts)
  local lsp_util = require("lspconfig.util")
  local path = lsp_util.path
  local result

  local _opts = {
    glob_pattern = { "*", ".*" },
    venv_folder = { "venv", ".venv" },
  }
  opts = vim.tbl_deep_extend("force", _opts, opts or {})

  local envvar = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
  if envvar then
    return path.join(envvar, "bin", "python")
  end

  workspace = workspace or vim.api.nvim_buf_get_name(0)
  workspace = vim.loop.fs_realpath(workspace)

  result = traverse_child(workspace, opts.glob_pattern, "pyvenv.cfg")
  local is_git_workspace = M.is_git_workspace()
  if not result and is_git_workspace then
    workspace = lsp_util.find_git_ancestor(workspace)
    result = traverse_child(workspace, opts.glob_pattern, "pyvenv.cfg")
  end

  if not result and not is_git_workspace then
    result =
      vim.fs.find(opts.venv_folder, { path = workspace, upward = true })[1]
  end

  if result then
    return path.join(result, "bin", "python")
  end

  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

return M
