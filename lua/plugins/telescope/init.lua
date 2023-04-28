return {
  {
    "nvim-telescope/telescope.nvim",
    version = "0.1.x",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension("fzf")
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    event = "UIEnter",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function()
      require("telescope").load_extension("ui-select")
    end
  },
}
