return {
  {"nvim-lua/plenary.nvim"},
  { 'echasnovski/mini.nvim', version = false },
  {'christoomey/vim-tmux-navigator'},
  {
    "iamcco/markdown-preview.nvim",
    lazy = false,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
}
