
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = {
        "lua", "javascript", "html", "go", "python", "json", "svelte", "toml", "typescript", "yaml",
        "markdown", "markdown_inline"
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end
}
