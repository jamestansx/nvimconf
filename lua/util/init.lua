local M = {}

M.autocmd = vim.api.nvim_create_autocmd
M.augroup = function(grp, opts)
  vim.api.nvim_create_augroup("Jamestansx_" .. grp, opts or { clear = true })
end

return M
