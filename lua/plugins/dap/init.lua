return {
  {
    "mfussenegger/nvim-dap",
    dependencies = "jay-babu/mason-nvim-dap.nvim",
    lazy = true,
    opts = {
      "python",
    },
    init = function()
      require("plugins.dap.keymaps")
    end,
    config = function(_, debuggers)
      require("mason-nvim-dap").setup({
        ensure_installed = debuggers,
        automatic_installation = true,
      })

      local dap = require("dap")
      for _, debugger in ipairs(debuggers) do
        local opts = require("plugins.dap.debuggers")[debugger]
        if opts then
          dap.adapters[debugger] = opts.adapters
          dap.configurations[debugger] = opts.configurations
        end
      end

      local dapui = require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      local sign = vim.fn.sign_define
      sign(
        "DapBreakpoint",
        { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" }
      )
      sign("DapBreakpointCondition", {
        text = "●",
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = "",
      })
      sign(
        "DapLogPoint",
        { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" }
      )
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = "mfussenegger/nvim-dap",
    lazy = true,
    init = function()
      vim.api.nvim_create_autocmd("BufWinEnter", {
        desc = "Set DAP UI window's winblend to 0",
        pattern = { "\\[dap-repl\\]", "DAP *" },
        callback = function(args)
          local win = vim.fn.bufwinid(args.buf)
          vim.api.nvim_win_set_option(win, "winblend", 0)
        end,
      })
    end,
    opts = {
      force_buffers = true,
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
        },
      },
      icons = {
        collapsed = "►",
        current_frame = "►",
        expanded = "▼",
      },
      layouts = {
        {
          elements = {
            "scopes",
            "breakpoints",
            "stacks",
            "watches",
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            "repl",
            "console",
          },
          size = 0.25,
          position = "bottom",
        },
      },
      render = { max_value_lines = 3 },
      floating = {
        max_width = 0.9,
        max_height = 0.5,
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      },
    },
  },
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = "nvim-telescope/telescope.nvim",
    lazy = true,
  },
}
