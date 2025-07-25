--return {
--  "zenbones-theme/zenbones.nvim",
--  dependencies = "rktjmp/lush.nvim",
--  lazy = false,
--  priority = 1000,
--  config = function()
--    vim.g.neobones = {
--      --darkness = 'stark',
--      lighten_noncurrent_window = true
--    }
--    vim.cmd.colorscheme 'neobones'
--    vim.cmd 'highlight ColorColumn guibg=#04131c'
--  end
--}

--return {
--  'ficcdaf/ashen.nvim',
--  lazy = false,
--  priority = 1000,
--  config = function()
--    vim.cmd 'colorscheme ashen'
--
--    vim.cmd [[
--        highlight DiagnosticError guifg=#2F4F4F
--        highlight DiagnosticWarn guifg=#2F4F4F
--        highlight DiagnosticInfo guifg=#2F4F4F
--        highlight DiagnosticHint guifg=#2F4F4F 
--        highlight ColorColumn guibg=#101010
--    ]]
--  end
--}

return {
  'projekt0n/github-nvim-theme',
  lazy = false,
  config = function()
    vim.cmd('colorscheme github_dark_default')
  end
}

--return {}
