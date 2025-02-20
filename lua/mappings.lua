require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local mp = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

mp("n", "<leader>pf", "<cmd>FzfLua files winopts.treesitter=true<cr>", opts)
mp("n", "<leader>pg", "<cmd>FzfLua live_grep<cr>", opts)    -- Live grep
mp("n", "<leader>pb", "<cmd>FzfLua buffers<cr>", opts)      -- Open buffers
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
