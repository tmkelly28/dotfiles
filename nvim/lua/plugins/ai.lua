return {
  {'github/copilot.vim'},
  {"zbirenbaum/copilot.lua"},
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      window = {
        layout = "vertical",
        width = 0.4,
        height = 0.4,
      },
      mappings = {
        reset = {
          normal = "<C-r>",
          insert = "<C-r>",
        },
      },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
  -- {
  --   "olimorris/codecompanion.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --     { 'github/copilot.vim', cmd = 'Copilot' },
  --   },
  --   config = function()
  --     require('codecompanion').setup({
  --       opts = {
  --         strategies = {
  --           chat = {
  --             adapter = 'copilot',
  --           },
  --           inline = {
  --             adapter = 'copilot',
  --           },
  --           agent = {
  --             adapter = 'copilot',
  --           },
  --         },
  --       },
  --       adapters = {
  --         copilot = function() return require('codecompanion.adapters').extend('copilot', {}) end,
  --       },
  --     })
  --   end,
  -- },
  -- {
  --   "yetone/avante.nvim",
  --   config = function()
  --     require('avante_lib').load()
  --     require('avante').setup({
  --       provider = 'copilot', -- claude, copilot
  --       auto_suggestions_provider = "copilot"
  --     })
  --   end,
  --   event = "VeryLazy",
  --   lazy = false,
  --   version = false, -- set this if you want to always pull the latest change
  --   opts = {
  --     -- provier = "copilot",
  --   },
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   build = "make",
  --   -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  --   dependencies = {
  --     "stevearc/dressing.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     --- The below dependencies are optional,
  --     "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
  --     "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
  --     "zbirenbaum/copilot.lua", -- for providers='copilot'
  --     {
  --       -- support for image pasting
  --       "HakonHarnes/img-clip.nvim",
  --       event = "VeryLazy",
  --       opts = {
  --         -- recommended settings
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           -- required for Windows users
  --           use_absolute_path = true,
  --         },
  --       },
  --     },
  --     {
  --       "MeanderingProgrammer/render-markdown.nvim",
  --       opts = {
  --         file_types = { "markdown", "Avante" },
  --       },
  --       ft = { "markdown", "codecompanion", "Avante" }
  --     },
  --   },
  -- }
}
