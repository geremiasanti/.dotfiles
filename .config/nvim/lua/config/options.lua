-- colors
--vim.cmd.colorscheme 'habamax'
--vim.cmd [[
--  highlight ColorColumn guibg=#101010
--  highlight DiagnosticError guifg=#36454F
--  highlight DiagnosticWarn guifg=#36454F
--  highlight DiagnosticInfo guifg=#36454F
--  highlight DiagnosticHint guifg=#708090
--]]

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Wrapping and associated option
vim.o.wrap = false
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'
vim.o.colorcolumn = '80'

-- Line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- keep cursor kinda centered
vim.opt.scrolloff = 10

-- tabs
-- handled by sleuth.vim
--vim.opt.tabstop = 4
--vim.opt.shiftwidth = 4

-- colors
vim.opt.termguicolors = true  

-- list mode/command (show whitespaces)
vim.opt.listchars = {
  tab = '>-',
  space = '␣',
  trail = '~',
  eol = '↵',
}

-- vertical splits open on the right
--vim.o.splitright = true
