return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      tsserver = {
        filetypes = { "javascript", "javascriptreact" }, -- Restrict to JavaScript
        settings = {
          javascript = {
            suggest = {
              completeFunctionCalls = true, -- Enable function call completions
              autoImports = true, -- Enable auto-imports
            },
          },
        },
      },
    },
  },
}
