local api = vim.api
local fn = vim.fn
local opt = vim.opt

local util = require("jamestansx.util")
local autocmd = api.nvim_create_autocmd
local augroup = util.augroup

vim.g.mapleader = " "
vim.g.maplocalleader = " "

opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.cursorline = true
opt.hlsearch = true
opt.confirm = true -- show confirmation instead of error
opt.autowriteall = true -- auto save when leaving neovim
opt.title = true
opt.laststatus = 3 -- global status
opt.showtabline = 1
opt.conceallevel = 2
opt.concealcursor = "nc" -- this is what vimdoc used
opt.synmaxcol = 300 -- don't syntax highlight long lines
opt.mouse = "a"
opt.signcolumn = "yes"
opt.virtualedit = "block"

-- TODO: recheck the session options
opt.sessionoptions = {
  "buffers",
  "curdir",
  "folds",
  "tabpages",
  "terminal",
  "winsize",
}
opt.spelllang = { "en" }
opt.spelloptions:append({ "camel", "noplainbuffer" })

-- show me the matching bracket when closing it
opt.showmatch = true
opt.matchtime = 2

-- keep my cursor away from screen edge
opt.scrolloff = 10
opt.sidescrolloff = 10

-- quick timeout
opt.timeoutlen = 250
opt.ttimeoutlen = 10
opt.redrawtime = 1000
opt.updatetime = 100

-- proper search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- smart completion
opt.infercase = true
opt.complete:append("kspell")
opt.completeopt = { "menu", "menuone", "noselect" }

-- decent wildmenu
opt.wildmode = { "longest:full", "full" }
opt.wildoptions = { "pum", "fuzzy", "tagfile" }
opt.wildignorecase = true
opt.wildignore:append({
  "*.out",
  "*.obj",
  "*.o",
  "*~",
  "*.pyc",
  "*pycache*",
  "*.swp",
  "*.gif",
  "*.png",
  "*.jpg",
  "*.jpeg",
  "*.ico",
  "*.wav",
  "*.mp3",
  "*.mp4",
  "*.lock",
})

-- please be smart about indentation
opt.autoindent = true
opt.smartindent = true
opt.cindent = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.shiftround = true
opt.expandtab = true

-- wrap smartly
opt.wrap = true
opt.breakindent = true
opt.linebreak = true
opt.showbreak = "↪···"
opt.breakindentopt = "sbr"
autocmd({ "BufEnter" }, {
  desc = "Set the formatoptions globally",
  group = augroup("GlobalFormatOptions"),
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions = {
      c = true, -- wrap comment using textwidth
      q = true, -- allow formatting comment w/ gq
      r = true, -- continue comment when pressing enter
      n = true, -- detect list for formatting
      j = true, -- autoremove comments if possible
    }
  end,
})

-- show hidden characters
opt.list = true
opt.listchars:append({
  space = "·",
  trail = "␣",
  tab = "··»",
  nbsp = "◻",
  extends = "→",
  precedes = "←",
  eol = "↲",
})

-- visible floating windows and popup menus
opt.pumblend = 10
opt.winblend = 10
opt.pumheight = 5 -- less is more

-- permenant undo list
opt.undofile = true
opt.undolevels = 10000

-- sane split
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

-- diff mode
opt.diffopt:append({
  "iwhite", -- no whitespace
  "hiddenoff", -- don't diff when buffer is hidden
  "linematch:60",
  "algorithm:histogram",
  "indent-heuristic",
})

-- window management
opt.winwidth = 15
opt.winminwidth = 15
opt.equalalways = false

-- less cluttering
opt.shortmess:append("WICc")
opt.showmode = false
opt.ruler = false

-- folding
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "0" -- no fold column
opt.foldenable = true
opt.foldmethod = "manual"
opt.fillchars:append({
  fold = " ",
  foldopen = "▽",
  foldsep = " ",
  foldclose = "▷",
})

-- set vimgrep
if 1 == fn.executable("rg") then
  opt.grepprg = "rg --vimgrep --no-heading --smart-case --hidden --glob '!.git'"
  opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

-- set python provider path
local python_path = fn.stdpath("data") .. "/venv"
if not vim.loop.fs_stat(python_path) then
  fn.jobstart("virtualenv " .. python_path, {
    on_exit = function(_, s)
      if 0 ~= s then
        vim.notify("Failed to init virtualenv", vim.log.levels.ERROR)
        return
      end
      fn.jobstart(
        string.format("%s/bin/python -m pip install pynvim", python_path),
        {
          on_exit = function(_, ret)
            if 0 ~= ret then
              vim.notify("Failed to install pynvim", vim.log.levels.ERROR)
              return
            end
            vim.g.python3_host_prog = python_path .. "/bin/python"
          end,
        }
      )
    end,
  })
else
  vim.g.python3_host_prog = python_path .. "/bin/python"
end
