return {
	{
    "ibhagwan/fzf-lua",
	lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({
			fzf_colors = true,
        grep = {
          cmd = "grep",
          grep_opts = "-n -r --color=always --ignore-case --exclude-dir=.git --exclude-dir=.objs",
			silent = true,
        },
        files = {
          prompt = "Files❯ ",
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
