local function trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
  return function(str)
    local win_width = 3 == vim.opt.laststatus and vim.o.columns
      or vim.fn.winwidth(0)

    if hide_width and win_width < hide_width then
      return ""
    elseif
      trunc_width
      and trunc_len
      and win_width < trunc_width
      and #str > trunc_len
    then
      return str:sub(1, trunc_len) .. (no_ellipsis and "" or "...")
    end
    return str
  end
end

local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

return {
  "nvim-lualine/lualine.nvim",
  event = "UIEnter",
  dependencies = "nvim-tree/nvim-web-devicons",
  opts = {
    options = {
      theme = "catppuccin",
      component_separators = { left = "|", right = "|" },
      section_separators = "",
      globalstatus = true,
    },
    sections = {
      lualine_a = {
        { "mode", fmt = trunc(80, 4, nil, true) },
      },
      lualine_b = {
        { "b:gitsigns_head", icon = "" },
        { "diff", source = diff_source },
        {
          "diagnostics",
          cond = function()
            return #vim.lsp.get_active_clients({ bufnr = vim.fn.bufnr() }) > 0
          end,
          icons_enabled = false,
          sources = { "nvim_lsp", "nvim_diagnostic" },
          update_in_insert = true,
          always_visible = true,
        },
      },
      lualine_c = {
        { "filename", fmt = trunc(90, 30, 50) },
      },
      lualine_x = {
        "searchcount",
        {
          function()
            local clients =
              vim.lsp.get_active_clients({ bufnr = vim.fn.bufnr() })
            local ft = vim.api.nvim_buf_get_option(0, "filetype")
            local icon = require("nvim-web-devicons").get_icon_by_filetype(ft)

            if clients and #clients > 0 then
              local names = {}
              for _, client in ipairs(clients) do
                table.insert(names, client.name)
              end
              return string.format("%s %s", table.concat(names, ", "), icon)
            else
              return ""
            end
          end,
          color = function()
            local ft = vim.api.nvim_buf_get_option(0, "filetype")
            local _, color =
              require("nvim-web-devicons").get_icon_cterm_color_by_filetype(ft)
            return { fg = color }
          end,
        },
      },
      lualine_y = {
        "encoding",
        {
          "fileformat",
          icons_enabled = false,
          symbols = {
            unix = "LF",
            dos = "CRLF",
            mac = "CR",
          },
        },
        { "filetype", icons_enabled = false },
      },
      lualine_z = { "progress" },
    },
    winbar = {
      lualine_a = {
        {
          function()
            return require("nvim-navic").get_location(
              { highlight = true },
              vim.fn.bufnr()
            )
          end,
          cond = function()
            return require("nvim-navic").is_available(vim.fn.bufnr())
          end,
        },
      },
      lualine_x = {
        {
          function()
            return string.format("[%s]", vim.api.nvim_win_get_number(0))
          end,
        },
      },
    },
    inactive_winbar = {
      lualine_a = {
        {
          function()
            return require("nvim-navic").get_location(
              { highlight = true },
              vim.fn.bufnr()
            )
          end,
          cond = function()
            return require("nvim-navic").is_available(vim.fn.bufnr())
          end,
        },
      },
      lualine_x = {
        {
          function()
            return string.format("[%s]", vim.api.nvim_win_get_number(0))
          end,
        },
      },
    },
    extensions = {
      --"drex",
    },
  },
}
