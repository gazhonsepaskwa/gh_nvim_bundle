require "nvchad.options"

-- add yours here!

local o = vim.o
local opt = vim.opt

o.cursorlineopt ='both'
o.expandtab = false
o.smartindent = true
o.smarttab = true
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 0
o.relativenumber = true
o.ignorecase = true
o.smartcase = true
o.mouse = "a"

opt.fillchars = { eob = " " }
opt.whichwrap:append "<>[]hl"
