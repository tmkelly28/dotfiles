-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  vim.keymap.set('n', 'x', api.node.navigate.parent_close,        opts('Close Directory'))
  vim.keymap.set('n', '?', api.tree.toggle_help,                  opts('Help'))
  vim.keymap.set("n", "r", api.tree.reload,                       opts("Refresh"))
  vim.keymap.set("n", "m", api.fs.rename_full,                         opts("Rename"))
end

vim.api.nvim_set_keymap('n', 'N', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- OR setup with some options
require("nvim-tree").setup({
  on_attach = my_on_attach,
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 45,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
    exclude = {
      "~/dotfiles/.zsh-local.zsh",
      "nvim/local.vim",
      ".tmux-local.conf",
    },
  },
  hijack_directories = {
    enable = false,
    auto_open = false,
  },
})

local function open_nvim_tree(data)
  if not data.file or data.file == "" then
    require("nvim-tree.api").tree.open()
    return
  end

  -- buffer is a directory
  local directory = vim.fn.isdirectory(data.file) == 1

  if not directory then
    return
  end

  -- change to the directory
  vim.cmd.cd(data.file)

  -- open the tree
  require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
vim.cmd("highlight NvimTreeNormal guibg=NONE ctermbg=NONE")
vim.cmd("highlight NvimTreeNormalNC guibg=NONE ctermbg=NONE")
vim.cmd("highlight NvimTreeWinSeparator guibg=NONE ctermbg=NONE")

-- close nvim-tree when it's the only window
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.fn.winnr('$') == 1 and vim.bo.filetype == 'NvimTree' then
      vim.cmd("quit")
    end
  end
})
