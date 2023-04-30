local M = {}
local util = require("jamestansx.util")

--{
--  "name": "Python: Flask",
--  "type": "python",
--  "request": "launch",
--  "module": "flask",
--  "env": {
--    "FLASK_APP": "app.py",
--    "FLASK_DEBUG": "1"
--  },
--  "args": [
--    "run",
--    "--no-debugger",
--    "--no-reload"
--  ],
--  "jinja": true,
--  "justMyCode": true
--},
--{
--  "name": "Python: FastAPI",
--  "type": "python",
--  "request": "launch",
--  "module": "uvicorn",
--  "args": [
--    "main:app"
--  ],
--  "jinja": true,
--  "justMyCode": true
--},
--{
--  "name": "Python: Django",
--  "type": "python",
--  "request": "launch",
--  "program": "${workspaceFolder}/manage.py",
--  "args": [
--    "runserver"
--  ],
--  "django": true,
--  "justMyCode": true
--},
--{
--  "name": "Python: Attach using Process Id",
--  "type": "python",
--  "request": "attach",
--  "processId": "${command:pickProcess}",
--  "justMyCode": true
--},
--{
--  "name": "Python: Pyramid Application",
--  "type": "python",
--  "request": "launch",
--  "module": "pyramid.scripts.pserve",
--  "args": [
--    "${workspaceFolder}/development.ini"
--  ],
--  "pyramid": true,
--  "jinja": true,
--  "justMyCode": true
--}
M.python = {
  adapters = {
    type = "executable",
    command = require("mason-registry")
      .get_package("debugpy")
      :get_install_path() .. "/venv/bin/python",
    args = { "-m", "debugpy.adapter" },
  },
  configurations = {
    {
      name = "Launch File",
      type = "python",
      request = "launch",
      program = "${file}",
      console = "integratedTerminal",
      pythonPath = util.path.get_python_path(),
      justMyCode = true,
    },
    {
      name = "Launch File with Arguments",
      type = "python",
      request = "launch",
      program = "${file}",
      args = function()
        local args = vim.fn.input("Arguments > ")
        return vim.split(args, " +")
      end,
      console = "integratedTerminal",
      pythonPath = util.path.get_python_path(),
    },
    {
      name = "Launch Module",
      type = "python",
      request = "launch",
      module = function()
        return vim.fn.expand("%:.:r:gs?/?.?")
      end,
      pythonPath = util.path.get_python_path(),
      console = "integratedTerminal",
      justMyCode = true,
    },
    {
      name = "Attach Remote",
      type = "python",
      request = "attach",
      connect = function()
        local host =
          util.is_empty(vim.fn.input("Host [127.0.0.1] > "), "127.0.0.1")
        local port = tonumber(vim.fn.input("Port [5678] > ")) or 5678
        return { host = host, port = port }
      end,
      justMyCode = true,
    },
  },
}

return M
