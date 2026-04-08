return { 
  'tpope/vim-fugitive',
  config = function()
    -- Cap fugitive window height to 12 lines whenever it opens
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'fugitive',
      callback = function()
        local max = 12
        if vim.api.nvim_win_get_height(0) > max then
          vim.api.nvim_win_set_height(0, max)
        end

        -- dd: open diff and close the fugitive window for max height
        vim.keymap.set('n', 'dd', function()
          local fugitive_win = vim.api.nvim_get_current_win()
          local keys = vim.api.nvim_replace_termcodes('<Plug>fugitive:dd', true, true, true)
          vim.api.nvim_feedkeys(keys, 'x', false)
          vim.schedule(function()
            if vim.api.nvim_win_is_valid(fugitive_win) then
              vim.api.nvim_win_close(fugitive_win, true)
            end
          end)
        end, { buffer = true })
      end,
    })

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

      -- If no fugitive window is visible, open it
      if not closed_something then
        vim.cmd 'G'
      end
    end, { noremap = true, silent = true })
  end
}
