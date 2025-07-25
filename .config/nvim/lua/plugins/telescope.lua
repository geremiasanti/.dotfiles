return {
  'nvim-telescope/telescope.nvim', branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>sf', builtin.find_files)
    vim.keymap.set('n', '<leader>sg', builtin.live_grep)
    vim.keymap.set('n', '<leader>sc', builtin.current_buffer_fuzzy_find)
    vim.keymap.set('n', '<leader>sb', builtin.buffers)
    vim.keymap.set('n', '<leader>sp', builtin.oldfiles)
    vim.keymap.set('n', '<leader>sr', builtin.resume)
    vim.keymap.set('n', '<leader>sd', builtin.help_tags)
    vim.keymap.set('n', '<leader>sw', builtin.grep_string)
  end 
}
