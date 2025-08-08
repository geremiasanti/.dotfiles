local function git_branches_completion(_, _, _)
  local handle = io.popen("git for-each-ref --format='%(refname:short)' refs/heads refs/remotes")
  if not handle then return {} end
  local result = {}
  for branch in handle:lines() do
    table.insert(result, branch)
  end
  handle:close()
  return result
end

return {
  'sindrets/diffview.nvim',
  config = function()
    vim.api.nvim_create_user_command(
      'Gfh', -- [G]it [f]ile [h]istory
      function(opts)
        -- if no args defaults to `%` (current file)
        local target = (opts.args ~= '' and opts.args) or vim.fn.expand('%')
        vim.cmd('DiffviewFileHistory ' .. target)
      end,
      { nargs = '*', complete = 'file' }
    )
    vim.api.nvim_create_user_command(
      -- "Gvd" is the fugitive single file diff
      -- this is the multiple file version of it, so it's capital "d"
      'GvD', -- [G]it [v]iew [D]iff 
      'DiffviewOpen <args>',
      { nargs = '*', complete = git_branches_completion }
    )
    vim.api.nvim_create_user_command(
      'Gvc',
      'DiffviewClose',
      { nargs = 0 }
    )
  end
}
