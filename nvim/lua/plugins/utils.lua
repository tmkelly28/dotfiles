return {
  {"nvim-lua/plenary.nvim"},
  { 'echasnovski/mini.nvim', version = false },
  {'christoomey/vim-tmux-navigator'},
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
}
