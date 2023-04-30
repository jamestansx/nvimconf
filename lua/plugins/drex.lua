return {
  "theblob42/drex.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  lazy = false,
  keys = {
    { "<leader>pv", "<Cmd>Drex<CR>" },
    { "<leader>pd", "<Cmd>DrexDrawerToggle<CR>" },
    { "<leader>pf", "<Cmd>DrexDrawerFindFileAndFocus<CR>" },
  },
  init = function()
    local augroup = require("jamestansx.util").augroup
    vim.api.nvim_create_autocmd("BufEnter", {
      desc = "Lock Drex windows to itself",
      group = augroup("DrexDrawerWindow"),
      pattern = "drex",
      callback = function(args)
        if
          vim.api.nvim_get_current_win()
          == require("drex.drawer").get_drawer_window()
        then
          local is_drex_buffer = function(b)
            local ok, syntax = pcall(vim.api.nvim_buf_get_option, b, "syntax")
            return ok and syntax == "drex"
          end
          local prev_buf = vim.fn.bufnr("#")

          if is_drex_buffer(prev_buf) and not is_drex_buffer(args.buf) then
            vim.api.nvim_set_current_buf(prev_buf)
            vim.schedule(function()
              vim.cmd([['"]]) -- restore former cursor position
            end)
          end
        end
      end,
    })
  end,
  opts = function()
    local utils = require("drex.utils")
    local files = require("drex.actions.files")
    local elements = require("drex.elements")

    return {
      hide_cursor = false,
      hijack_netrw = true,
      drawer = {
        window_picker = {
          labels = "asdfjklgh",
        },
      },
      keybindings = {
        ["n"] = {
          ["q"] = "<Cmd>DrexDrawerClose<CR>",
          ["A"] = function()
            local line = vim.api.nvim_get_current_line()
            files.create(utils.get_path(line))
          end,
          ["a"] = function()
            local line = vim.api.nvim_get_current_line()
            if utils.is_directory(line) then
              files.create(utils.get_element(line) .. utils.path_separator)
            else
              -- fallback to same level if element is not a directory
              files.create(utils.get_path(line))
            end
          end,
          ["l"] = function()
            local start = vim.api.nvim_win_get_cursor(0) -- OPTIONAL

            while true do
              elements.expand_element()

              local row = vim.api.nvim_win_get_cursor(0)[1]
              local lines =
                vim.api.nvim_buf_get_lines(0, row - 1, row + 2, false)

              -- special case for files
              if lines[1] and not utils.is_directory(lines[1]) then
                return
              end

              -- check if a given line is a child element of the expanded element
              local is_child = function(l)
                if not l then
                  return false
                end
                return vim.startswith(
                  utils.get_element(l),
                  utils.get_element(lines[1]) .. utils.path_separator
                )
              end

              if
                is_child(lines[2])
                and utils.is_directory(lines[2])
                and not is_child(lines[3])
              then
                vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
              else
                vim.api.nvim_win_set_cursor(0, start) -- OPTIONAL
                return
              end
            end
          end,
          -- expand every directory in the current buffer
          ["E"] = function()
            local row = 1
            while true do
              local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
              if utils.is_closed_directory(line) then
                elements.expand_element(0, row)
              end
              row = row + 1

              if row > vim.fn.line("$") then
                break
              end
            end
          end,
          -- collapse every directory in the current buffer
          ["C"] = function()
            local row = 1
            while true do
              local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
              if utils.is_open_directory(line) then
                elements.collapse_directory(0, row)
              end
              row = row + 1

              if row > vim.fn.line("$") then
                break
              end
            end
          end,
        },
      },
    }
  end,
  config = function(_, opts)
    require("drex.config").configure(opts)
  end,
}
