return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },
  opts = {
    -- Un-render the block the cursor is in so it can be edited as raw text.
    render_modes = { "n", "c", "t" },
    anti_conceal = { enabled = true },
    heading = {
      width = "block",
      left_pad = 0,
      right_pad = 2,
    },
    code = {
      width = "block",
      right_pad = 2,
    },
    pipe_table = {
      preset = "round",
      alignment_indicator = "",
    },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)

    -- Markdown reads better wrapped at word boundaries; the global default is nowrap.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.conceallevel = 3
      end,
    })

    vim.keymap.set("n", "<leader>rm", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle markdown rendering" })
  end,
}
