-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "tokyonight-moon" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

vim.cmd[[colorscheme tokyonight-moon]]

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
  indent = {
    enable = true
  }
}

require('render-markdown').setup({
  heading = {
    backgrounds = {
      'RenderMarkdownH1Bg',
      'RenderMarkdownH2Bg',
      'RenderMarkdownH3Bg',
      'RenderMarkdownH4Bg',
      'RenderMarkdownH5Bg',
      'RenderMarkdownH6Bg',
    },
    -- The 'level' is used to index into the list using a clamp
    -- Highlight for the heading and sign icons
    foregrounds = {
      'RenderMarkdownH1',
      'RenderMarkdownH2',
      'RenderMarkdownH3',
      'RenderMarkdownH4',
      'RenderMarkdownH5',
      'RenderMarkdownH6',
    },
  }
})

require('copilot').setup()

-- require('avante_lib').load()
-- require('avante').setup ({
--   provider = 'copilot', -- claude, copilot
--   auto_suggestions_provider = "copilot"
-- })
require('codecompanion').setup(
  {
    strategies = {
      chat = {
        adapter = "copilot",
      },
      inline = {
        adapter = "copilot",
      },
      agent = {
        adapter = "copilot",
      },
    },
  }
)

require('pairs'):setup(
  {
    indent = {
      python = 0,
    }
  }
)

require('lualine').setup(
  {
    options = {
      theme = 'palenight',
    }
  }
)
require("bufferline").setup(
  {
    highlights = {
      fill = {
        bg = '#222334',
        fg = '#cad2f2',
      }
    }
  }
)
