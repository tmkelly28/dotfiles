-- require'nvim-treesitter.configs'.setup {
--   indent = {
--     enable = true
--   }
-- }
require("CopilotChat").setup {
  debug = true, -- Enable debugging
  -- See Configuration section for rest
}

require('avante_lib').load()
require('avante').setup ({
  provider = 'copilot', -- claude, copilot
  auto_suggestions_provider = "copilot"
})
