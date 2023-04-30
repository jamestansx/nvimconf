return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "SmiteshP/nvim-navic",
      "ray-x/lsp_signature.nvim",
      "hrsh7th/cmp-nvim-lsp",
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
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_installation = true,
      })

      local defaults = require("plugins.lsp.defaults")
      local _ = defaults.handlers
      local capabilities = defaults.capabilities
      local on_attach = defaults.on_attach

      for _, server in ipairs(servers) do
        local opts = require("plugins.lsp.servers")[server] or {}
        opts = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = on_attach,
        }, opts)
        require("lspconfig")[server].setup(opts)
      end
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "jay-babu/mason-null-ls.nvim",
    },
    opts = {
      "stylua",
    },
    config = function(_, providers)
      require("mason-null-ls").setup({
        ensure_installed = providers,
        automatic_installation = true,
      })

      local nls = require("null-ls")
      nls.setup({
        sources = {
          nls.builtins.formatting.stylua.with({
            condition = function(utils)
              return utils.root_has_file({ "stylua.toml", ".stylua.toml" })
            end,
          }),
        },
        on_attach = require("plugins.lsp.keymaps").on_attach,
      })
    end,
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      window = {
        relative = "editor",
        blend = 0,
      },
      text = { spinner = "meter" },
      sources = {
        ["null-ls"] = { ignore = true },
      },
    },
  },
  {
    "ray-x/lsp_signature.nvim",
    version = false,
    event = "LspAttach",
    opts = {
      bind = true,
      toggle_key = "<M-p>",
      max_width = 80,
      hint_enable = false,
      floating_window = false,
      handler_opts = { border = "none" },
      floating_window_above_cur_line = true,
    },
  },
  {
    "zbirenbaum/neodim",
    event = "LspAttach",
    config = true,
  },
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    opts = { highlight = true },
  },
}
