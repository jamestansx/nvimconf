local cmd = require("hydra.keymap-util").cmd
local hydra = require("hydra")
local util = require("jamestansx.util")

hydra({
  name = "DAP",
  mode = { "n" },
  config = {
    color = "pink",
    invoke_on_body = true,
    hint = {
      type = "window",
      position = "middle-right",
      border = "single",
    },
    on_enter = function()
      require("telescope").load_extension("dap")
    end,
  },
  hint = [[
Breakpoints:
_t_: Toggle Breakpoint
_T_: Set Conditional Breakpoint
_*_: List Breakpoints
_X_: Clear All Breakpoints
^
Debugger:
_C_: Start Debugger
_|_: Continue till cursor
_R_: Restart Debugger
_S_: Terminate Debugger
^
Step:
_H_: Step Back
_J_: Step Into
_K_: Step Out
_L_: Step Over
^
REPL:
_=_: Open Live REPL
^
UI:
_?_: Evaluate Expression
_+_: Add Watch Expression
_M_: Open Scope Float Window
^
_q_/_<F5>_: Exit DAP
]],
  body = "<F5>",
  heads = {
    -- breakpoint
    {
      "t",
      cmd("lua require('dap').toggle_breakpoint()"),
      { desc = "Toggle breakpoint", silent = true },
    },
    {
      "T",
      function()
        local cond = util.is_empty(vim.fn.input("Condition > "))
        local hit_cond = util.is_empty(vim.fn.input("Hit Condition > "))
        local log = util.is_empty(vim.fn.input("Log message > "))

        require("dap").set_breakpoint(cond, hit_cond, log)
      end,
      { desc = "Set conditional breakpoint", silent = true },
    },
    {
      "*",
      cmd("lua require('telescope').extensions.dap.list_breakpoints()"),
      { desc = "List breakpoints", silent = true },
    },
    {
      "X",
      cmd("lua require('dap').clear_breakpoints()"),
      { desc = "Clear all breakpoints", silent = true },
    },

    -- debugger
    {
      "C",
      cmd("lua require('telescope').extensions.dap.configurations()"),
      { desc = "Start debugger", silent = true },
    },
    {
      "R",
      cmd("lua require('dap').restart()"),
      { desc = "Restart debugger", silent = true },
    },
    {
      "S",
      cmd("lua require('dap').terminate()"),
      { desc = "Terminate debugger", silent = true },
    },
    {
      "|",
      cmd("lua require('dap').run_to_cursor()"),
      { desc = "Continue till cursor", silent = true },
    },

    -- Step
    {
      "H",
      cmd("lua require('dap').step_back()"),
      { desc = "Step back", silent = true },
    },
    {
      "J",
      cmd("lua require('dap').step_into()"),
      { desc = "Step into", silent = true },
    },
    {
      "K",
      cmd("lua require('dap').step_out()"),
      { desc = "Step out", silent = true },
    },
    {
      "L",
      cmd("lua require('dap').step_over()"),
      { desc = "Step over", silent = true },
    },

    -- REPL
    {
      "=",
      cmd("lua require('dapui').float_element('repl')"),
      { desc = "Open live REPL", silent = true },
    },

    -- UI
    {
      "?",
      function()
        local expression = util.is_empty(vim.fn.input("expression > "))
        return expression and require("dapui").eval(expression)
          or require("dapui").eval()
      end,
      {
        desc = "Evaluate expression",
        nowait = true,
        silent = true,
        mode = { "n", "v" },
      },
    },
    {
      "+",
      cmd("lua require('dapui').elements.watches.add()"),
      { desc = "Add watch expression", silent = true },
    },
    {
      "M",
      cmd("lua require('dapui').float_element('scopes')"),
      { desc = "Open scope float window", silent = true },
    },

    {
      "q",
      nil,
      { exit = true, nowait = true, desc = "Exit DAP" },
    },
    {
      "<F5>",
      nil,
      { exit = true, nowait = true, desc = "Exit DAP" },
    },
  },
})
