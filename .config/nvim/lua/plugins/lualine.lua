return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('lualine').setup({
          sections = {
            lualine_b = {'filename'},
            lualine_c = {'branch', 'diff'},
            lualine_x = {'diagnostics'},
          },
          options = {
            section_separators = { left = '', right = '' },
            component_separators = { left = '', right = '' }
          }
        })
    end
}
