return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    event = "BufReadPost",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "JoosepAlviste/nvim-ts-context-commentstring",
      "RRethy/nvim-treesitter-endwise",
      "windwp/nvim-ts-autotag",
      { "nvim-treesitter/nvim-treesitter-context", config = true },
    },
    opts = {
      ensure_installed = {
        "lua",
        "c",
        "python",
        "rust",
        "ron",
        "vimdoc",
      },
      autotag = { enable = true },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      endwise = { enable = true },
      fold = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<M-s>",
          node_incremental = "<M-s>",
          scope_incremental = "<M-S-s>",
          node_decremental = "<M-d>",
        },
      },
      playground = {
        enable = true,
        updatetime = 25,
        persist_queries = true,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@conditional.outer",
            ["ic"] = "@conditional.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["av"] = "@variable.outer",
            ["iv"] = "@variable.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
          },
        },
      },
      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "nvim-treesitter/playground",
    dependencies = "nvim-treesitter/nvim-treesitter",
    cmd = "TSPlaygroundToggle",
  },
}
