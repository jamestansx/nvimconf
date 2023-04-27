local api = vim.api
local fn = vim.fn
local uv = vim.loop

local util = require("util")
local autocmd = util.autocmd
local augroup = util.augroup

autocmd({ "TextYankPost" }, {
  desc = "Highlight text on yank",
  group = augroup("HlTextYank"),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 50,
    })
  end,
})

autocmd({ "BufReadPost" }, {
  desc = "Restore last loc when opening a buffer",
  group = augroup("RestoreLastLoc"),
  pattern = "*",
  callback = function()
    local mark = api.nvim_buf_get_mark(0, '"')
    local lcount = api.nvim_buf_line_count(0)
    if 0 < mark[1] and lcount >= mark[1] then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
