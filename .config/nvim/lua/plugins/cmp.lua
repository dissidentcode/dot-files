return {
  "hrsh7th/nvim-cmp",
  opts = {
    sources = {
      { name = "nvim_lsp" }, -- Use LSP for completions
      { name = "buffer" }, -- Suggest from the current buffer
      { name = "path" }, -- Suggest file paths
    },
  },
}
