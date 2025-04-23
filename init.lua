vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"
require "custom.function_lines"

local cpp_gen = require("custom.cpp_gen")
vim.api.nvim_create_user_command("GenCPPFile", function(opts)
	cpp_gen.generate_cpp_file(opts.args)
end, {nargs = "?"})
local hpp_gen = require("custom.hpp_gen")
vim.api.nvim_create_user_command("GenHPPFile", function(opts)
	hpp_gen.generate_hpp_file(opts.args)
end, {nargs = 1})

vim.schedule(function()
  require "mappings"
end)
-- auto added code by nalebrun header42
local header = require('header')
vim.api.nvim_create_user_command(
    'Header',
    function()
        header.insert_header()
    end,
    {}
)
