if vim.loader then
  vim.loader.enable()
end

require("util").lazy_notify()

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
