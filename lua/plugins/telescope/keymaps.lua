local M = {}
local util = require("jamestansx.util.keymap")
local t = util.map_tele

---@type table
M._keymaps = nil

---@return table
function M.get()
  if not M._keymaps then
    M._keymaps = {
      {
        mode = "n",
        "<leader>ff",
        t(function()
          return require("jamestansx.util.path").is_git_worktree()
              and "git_files"
            or "find_files"
        end, { theme = "ivy" }),
        desc = "[F]ind [F]iles",
      },
      {
        mode = "n",
        "<leader>fh",
        t("help_tags"),
        desc = "[F]ind [H]elp",
      },
      {
        mode = "n",
        "<leader>fw",
        t("grep_string", {
          word_match = "-w",
          short_path = true,
          only_sort_text = true,
          layout_strategy = "vertical",
        }),
        desc = "[F]ind current [W]ord",
      },
      {
        mode = "n",
        "<leader>fg",
        t("live_grep", {
          previewer = false,
        }),
        desc = "[F]ind by [G]rep",
      },
    }
  end
  return M._keymaps
end

return M
