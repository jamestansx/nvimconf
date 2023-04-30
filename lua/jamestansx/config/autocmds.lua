local api = vim.api
local fn = vim.fn
local uv = vim.loop

local util = require("jamestansx.util")
local autocmd = api.nvim_create_autocmd
local augroup = util.augroup
local map = util.keymap.map

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

autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check if buffer were changed outside of neovim",
  group = augroup("CheckTime"),
  pattern = "*",
  command = [[checktime]],
})

local togglecursorline = augroup("ToggleCursorLine")
autocmd({ "InsertLeave", "WinEnter", "BufEnter" }, {
  desc = "Auto show cursorline",
  group = togglecursorline,
  pattern = "*",
  callback = function(ev)
    if ev.event == "InsertLeave" then
      vim.opt_local.cursorlineopt = "both"
    end
    if not vim.opt_local.cursorline:get() then
      vim.opt_local.cursorline = true
    end
  end,
})

autocmd({ "InsertEnter", "WinLeave", "BufLeave" }, {
  desc = "Auto hide cursorline",
  group = togglecursorline,
  pattern = "*",
  callback = function(ev)
    if ev.event == "InsertEnter" then
      vim.opt_local.cursorlineopt = "number"
      return
    end
    if vim.opt_local.cursorline:get() then
      vim.opt_local.cursorline = false
    end
  end,
})

autocmd({ "BufWritePre" }, {
  desc = "Create directories if needed when saving a file",
  group = augroup("MkdirOnSave"),
  pattern = "*",
  callback = function(ev)
    local file = uv.fs_realpath(ev.match) or ev.match
    pcall(fn.mkdir, fn.fnamemodify(file, ":p:h"), "p")
  end,
})

autocmd({ "VimEnter" }, {
  desc = "Set cwd when opening Neovim",
  group = augroup("AutoCwd"),
  pattern = "*",
  callback = function(ev)
    if "directory" ~= fn.isdirectory(fn.expand(ev.file)) then
      return
    end
    local dir = fn.fnamemodify(ev.file, ":p:h")
    pcall(api.nvim_set_current_dir, dir:match("^drex://(.*)$") or dir)
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  desc = "Prevent accidental write to buffers that shouldn't be editted",
  group = augroup("NoWrite"),
  pattern = {
    "*.orig",
    "*.pacnew",
  },
  command = [[setlocal nomodifiable]],
})

autocmd({ "BufWritePre" }, {
  desc = "Don't save undo on certain files",
  group = augroup("NoUndo"),
  pattern = {
    "/tmp/*",
    "COMMIT_EDITMSG",
    "MERGE_MSG",
    "*.tmp",
    "*.bak",
  },
  command = [[setlocal noundofile]],
})

autocmd({ "FileType" }, {
  desc = "Close filetypes with <q>",
  group = augroup("KeymapQuit"),
  pattern = {
    "tsplayground",
    "checkhealth",
    "startuptime",
    "lspinfo",
    "notify",
    "help",
    "man",
    "qf",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    map("n", "q", "<Cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})

local setft = augroup("SetFt")
autocmd({ "BufRead", "BufNewFile" }, {
  group = setft,
  pattern = "*.env*",
  command = [[setfiletype env]],
})
