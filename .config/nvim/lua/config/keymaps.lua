-- esc insert mode
--vim.keymap.set('i', 'lk', '<esc>')

-- remove hl from search results
vim.keymap.set('n', '<esc>', ':noh<cr>')

-- file explorer
vim.keymap.set('n', '-', ':Explore<CR>')

-- run last command easily
--local def_opts = { silent = false, noremap = true }
--vim.keymap.set({ 'n', 'v' }, '<Tab>', ':<up>', def_opts)

-- substitute
local substitute = require('substitute') 
vim.keymap.set("n", "s", substitute.operator, { noremap = true })
vim.keymap.set("n", "ss", substitute.line, { noremap = true })
vim.keymap.set("n", "S", substitute.eol, { noremap = true })
vim.keymap.set("x", "s", substitute.visual, { noremap = true })

-- navigate panes with alt+hjkl
vim.keymap.set('n', '<A-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<A-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<A-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<A-l>', '<C-w>l', { noremap = true, silent = true })
