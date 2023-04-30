return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    event = "BufReadPost",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/playground",
      "JoosepAlviste/nvim-ts-context-commentstring",
      "RRethy/nvim-treesitter-endwise",
      "windwp/nvim-ts-autotag",
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          -- Only the textobjects.scm is needed for mini.ai
          require("lazy.core.loader").disable_rtp_plugin(
            "nvim-treesitter-textobjects"
          )
        end,
      },
      { "nvim-treesitter/nvim-treesitter-context", config = true },
    },
    opts = {
      ensure_installed = {
        "lua",
        "c",
        "html",
        "python",
        "query",
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
      query_linter = { enable = true },
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
        persist_queries = true,
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
}
