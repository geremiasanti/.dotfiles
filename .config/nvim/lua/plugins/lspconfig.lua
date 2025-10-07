function lsp_keymap(bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  --vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  --vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  --vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  --vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  --vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  --vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
end

return {
  'neovim/nvim-lspconfig',
  config = function()
    local lspconfig = require('lspconfig')
    local lspconfig_util = require("lspconfig.util") 

    lspconfig.ruby_lsp.setup({
      on_attach = function(client , bufnr)
        lsp_keymap(bufnr)
      end
    })

    lspconfig.ts_ls.setup({
      on_attach = function(client , bufnr)
        lsp_keymap(bufnr)
      end
    })

    local local_eslint = vim.fn.getcwd() .. "/node_modules/.bin/vscode-eslint-language-server"
    local cmd = { "vscode-eslint-language-server", "--stdio" }
    if vim.fn.filereadable(local_eslint) == 1 then
      -- use project eslint installation if present
      cmd = { "node", local_eslint, "--stdio" }
    end
    lspconfig.eslint.setup({
      cmd = cmd,
      root_dir = lspconfig_util.root_pattern("eslint.config.js", "package.json"),
      on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          command = "EslintFixAll",
        })
      end,
    })

    lspconfig.cssls.setup {
      settings = {
        css = { validate = true },
        scss = { validate = true },
        less = { validate = true },
      }
    }
    lspconfig.stylelint_lsp.setup {
      settings = {
        stylelintplus = {
          configFile = '/home/geremia/.config/nvim/.stylelintrc.json',
          configBasedir = '/home/geremia/.config/nvim', -- needed if your config uses extends/plugins
          autoFixOnSave = false,
          -- optional:
          -- validateOnSave = true,
          -- validateOnType = true,
          -- configOverrides = {},
        },
      },
      filetypes = { 'css', 'scss', 'sass', 'less', 'vue' },
      root_dir = lspconfig.util.root_pattern('.git'),
    }

    -- config
    vim.diagnostic.config({
      underline = false,
      signs = false,
    })

    -- keymaps
    vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
  end
}
