return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function () 
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "javascript", "html", "ruby" },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },  
    })

    --vim.api.nvim_create_autocmd("FileType", {
    --  pattern = "ruby",
    --  callback = function()
    --    vim.cmd("TSBufDisable highlight")
    --  end
    --})
  end
}
