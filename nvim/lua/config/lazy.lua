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
  -- automatically check for plugin updates every day
  checker = { enabled = true, frequency = 86400 },
})

vim.cmd[[colorscheme tokyonight-moon]]

require'nvim-treesitter'.setup()

-- Install parsers if missing (async, non-blocking)
local ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "go", "typescript", "yaml", "hcl" }
local installed = {}
for _, p in ipairs(require'nvim-treesitter'.get_installed()) do
  installed[p] = true
end
local to_install = vim.tbl_filter(function(p) return not installed[p] end, ensure_installed)
if #to_install > 0 then
  require'nvim-treesitter'.install(to_install)
end

-- Enable treesitter-based indentation
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    if pcall(vim.treesitter.start) then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

require('render-markdown').setup({ latex = { enabled = false } })

require('copilot').setup()
-- require('avante_lib').load()
-- require('avante').setup({
--   provider = 'claude', -- claude, copilot
--   auto_suggestions_provider = "copilot"
-- })

require('pairs')

require('lualine').setup(
  {
    options = {
      theme = 'palenight',
    }
  }
)
require("bufferline").setup()

vim.cmd [[
  highlight BufferLineFill guibg=NONE
  highlight BufferLineBackground guibg=NONE
]]

require('mini.splitjoin').setup()
