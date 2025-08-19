local function check_tabline_visibility()
  local any_mark = require('harpoon.mark').get_length() > 0
  vim.opt.showtabline = any_mark and 2 or 0
  return any_mark
end

return {
  'ThePrimeagen/harpoon', 
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    -- conf
    require('harpoon').setup({
      global_settings = { mark_branch = true, },
      menu = { width = 90 },
      tabline = true,
      tabline_prefix = '   ',
      tabline_suffix = '   '
    })
    -- keymaps
    vim.keymap.set('n', '<leader>a', require('harpoon.mark').add_file)
    vim.keymap.set('n', '<leader><leader>', require('harpoon.ui').toggle_quick_menu)
    vim.keymap.set('n', '<leader>p', require('harpoon.ui').nav_prev)
    vim.keymap.set('n', '<leader>n', require('harpoon.ui').nav_next)
    for i=1,8 do
      vim.keymap.set('n', '<leader>'..i, function() require('harpoon.ui').nav_file(i) end)
    end
    -- tabline style
    --vim.cmd('highlight! HarpoonNumberActive guibg=NONE guifg=#8190D4 gui=bold cterm=bold')
    --vim.cmd('highlight! HarpoonActive guibg=NONE guifg=#white')
    --vim.cmd('highlight! HarpoonNumberInactive guibg=#20303A guifg=#8190D4 gui=bold cterm=bold')
    --vim.cmd('highlight! HarpoonInactive guibg=#20303A guifg=#939E99')
    -- tabline redraw and visibility
    check_tabline_visibility()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'FugitiveChanged',
      callback = function()
        if check_tabline_visibility() then
          vim.cmd('redrawt')
        end
      end,
    })
    local marked = require('harpoon.mark')
    marked.on('changed', function()
      check_tabline_visibility()
    end)
  end,
}
