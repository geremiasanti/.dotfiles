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

    -- servers
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
    lspconfig.eslint.setup({
      on_attach = function(client, bufnr)
        lsp_keymap(bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          command = "EslintFixAll",
        })
      end,
    })
    local lspconfig_util = require("lspconfig.util") 
    require("lspconfig").eslint.setup({
      -- use local eslint installation 
      cmd = { "node", vim.fn.getcwd() .. "/node_modules/.bin/vscode-eslint-language-server", "--stdio" },
      root_dir = lspconfig_util.root_pattern("eslint.config.js", "package.json"),
      on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          command = "EslintFixAll",
        })
      end,
    })

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
