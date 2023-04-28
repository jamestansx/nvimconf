return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      --"williamboman/mason-lspconfig.nvim",
      "SmiteshP/nvim-navic",
      "ray-x/lsp_signature.nvim",
      {
        "hrsh7th/cmp-nvim-lsp",
        cond = require("util").has("nvim-cmp")
      },
      {
        "SmiteshP/nvim-navbuddy",
        dependencies = {
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim",
        },
      },
    },
    opts = {
      "lua_ls",
    },
    config = function(_, servers)
      local _ = require("plugins.lsp.handlers")
      local default = require("plugins.lsp.default")
      local on_attach = default.on_attach
      local capabilities = default.capabilities

      for _, server in ipairs(servers) do
        local opts = require("plugins.lsp.servers")[server]
        opts = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = on_attach,
        }, opts or {})
        require("lspconfig")[server].setup(opts)
      end
    end,
  },
}
