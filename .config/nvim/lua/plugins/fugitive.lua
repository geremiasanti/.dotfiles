return { 
  'tpope/vim-fugitive',
  config = function()
    vim.keymap.set('n', '<leader>g', function()

      -- If fugitive or git windows already visible, close the windows
      local closed_something = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
        if filetype == 'fugitive' or filetype == 'git' then
          vim.api.nvim_win_close(win, true)
          closed_something = true
        end
      end

      -- If no fugitive window is visible, and closed, open it and resize
      if not closed_something then
        vim.cmd 'G | resize 12'
      end
    end, { noremap = true, silent = true })
  end
}
