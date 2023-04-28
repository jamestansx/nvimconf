local util = require("util")
local map = util.keymaps

-- why not?
map({ "n", "v" }, { "<Space>", "<Nop>" })

-- easy switching windows with numbers
for i = 1, 5 do
  local lhs = string.format("<M-%s>", i)
  local rhs = string.format("%s<C-w>w", i)
  util.keymaps(
    "n",
    {
      lhs,
      rhs,
      { desc = string.format("Move to window tag '%s'", i), noremap = true },
    }
  )
end

-- jump to start and end of line with home row keys
map({ "n", "v", "s", "o" }, { { "H", "^" }, { "L", "$" } })

map("n", {
  -- search result centered please
  { "n", "nzzzv", { noremap = true, silent = true } },
  { "N", "Nzzzv", { noremap = true, silent = true } },
  { "*", "*zzzv", { noremap = true, silent = true } },
  { "#", "#zzzv", { noremap = true, silent = true } },
  { "g*", "g*zzzv", { noremap = true, silent = true } },

  -- smart j/k
  { "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true } },
  { "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true } },

  -- join line without moving cursor
  { "J", "mzJ`z", { noremap = true } },

  -- center screen when scrolling screen
  { "<C-d>", "<C-d>zz" },
  { "<C-u>", "<C-u>zz" },
})

map("x", {
  { ">", ">gv", { noremap = true } },
  { "<", "<gv", { noremap = true } },
})

map("c", {
  -- https://github.com/mhinz/vim-galore#saner-command-line-history
  {
    "<C-n>",
    function()
      return vim.fn.wildmenumode() == 1 and "<C-n>" or "<Down>"
    end,
    { expr = true, noremap = true },
  },
  {
    "<C-p>",
    function()
      return vim.fn.wildmenumode() == 1 and "<C-p>" or "<Up>"
    end,
    { expr = true, noremap = true },
  },
})

map("i", {
  { "<C-h>", "<Left>", { noremap = true, silent = true } },
  { "<C-j>", "<Down>", { noremap = true, silent = true } },
  { "<C-k>", "<Up>", { noremap = true, silent = true } },
  { "<C-l>", "<Right>", { noremap = true, silent = true } },
})

map("t", {
  {
    "<C-Esc>",
    "<C-\\><C-n>",
    { noremap = true, silent = true, desc = "Back to normal mode" },
  },
})
