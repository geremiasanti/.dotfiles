return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('lualine').setup({
          sections = {
            lualine_b = {'branch', 'filename'},
            lualine_c = {'diff'},
            lualine_x = {'diagnostics'},
          },
        })
    end
}
