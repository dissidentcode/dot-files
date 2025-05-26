return {
  "Pocco81/auto-save.nvim",
  config = function()
    require("auto-save").setup({
      enabled = true, -- Enable auto-save on start
      execution_message = {
        message = function()
          return "" -- Suppress save messages
        end,
      },
      trigger_events = { "InsertLeave", "TextChanged" }, -- Save when exiting insert mode or typing
      debounce_delay = 50, -- Delay before saving (in milliseconds)
    })
  end,
}
