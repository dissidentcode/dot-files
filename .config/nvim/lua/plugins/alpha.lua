return {
  "goolord/alpha-nvim",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- ASCII logo (without extra quotes)
    local logo = [[

              ██████ ████████████████████████     █████          █████████         
       ██████████████████████               █████        █ ███ ███████████████
               █████████████████████████████████ ███████████████████          
              ██████████████  █████  █████████████ ██████ ████████████████          
             ██████████████████████ ██████████████ ██████ ██████ ████ ██████          
           ██████ ███████ █████   █████████████ ██████ ██████ ████ ███████        
█████████████████████████████████████████████████████████████████████    
                                   [ @KeyLuminaries ]                                         
]]

    local logo_lines = vim.split(logo, "\n", { trimempty = true })

    --Add vertical padding (adjust number to taste)
    for _ = 1, 3 do
      table.insert(logo_lines, 1, "")
    end

    dashboard.section.header.val = logo_lines

    -- Button actions
    dashboard.section.buttons.val = {
      dashboard.button("n", "  New file", ":ene <BAR> startinsert<CR>"),
      dashboard.button("f", "󰈞  Find file", ":Telescope find_files<CR>"),
      dashboard.button("r", "  Recently opened files", ":Telescope oldfiles<CR>"),
      dashboard.button("g", "  Grep word", ":Telescope live_grep<CR>"),
      dashboard.button("b", "  Browse files", ":Neotree toggle<CR>"),
      dashboard.button(".", "  Edit config", ":e ~/.config/nvim/init.lua<CR>"),
      dashboard.button("p", "  Plugin files", ":Telescope find_files cwd=~/.config/nvim/lua/plugins<CR>"),
      dashboard.button("c", "  Colorscheme", ":Telescope colorscheme<CR>"),
      dashboard.button("q", "  Quit", ":qa<CR>"),
    }

    -- Final setup
    alpha.setup(dashboard.config)
  end,
}
