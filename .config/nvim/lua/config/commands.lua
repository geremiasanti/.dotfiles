-- copy relative path of current buffer's file
local function copy_relpath()
  local relpath = vim.fn.expand('%')
  vim.fn.setreg('+', relpath)
  print('Copied: ' .. relpath)
end
for _, name in ipairs({ 'CopyRelPath', 'CRPath' }) do
  vim.api.nvim_create_user_command(name, copy_relpath, {})
end

-- .rb files only: format current file with rubocop
vim.api.nvim_create_autocmd("FileType", {
  pattern = "ruby",
  callback = function(args)
    vim.keymap.set(
      "n",
      "<leader>f",
      function()
        vim.cmd('silent! !bundle exec rubocop -a %')
        vim.cmd('edit') -- Reload the buffer in case rubocop made changes
      end,
      { buffer = args.buf, noremap = true, silent = true }
    )
  end,
})
