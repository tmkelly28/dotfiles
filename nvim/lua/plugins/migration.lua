return {
  {'ZhiyuanLck/smart-pairs'},
  {'christoomey/vim-tmux-navigator'},
  { "nvim-tree/nvim-web-devicons" },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({})
    end
  },
  {"junegunn/fzf", build = "./install --bin"},
  {'moll/vim-bbye'},
  {'scrooloose/nerdtree'},

  -- Appearance
  -- {
  --   'wilmanbarrios/palenight.nvim',
  --   lazy = false,
  --   priority = 1000,
  -- },
  {
    'drewtempelmeyer/palenight.vim',
    lazy = false,
    priority = 1000,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},


  {'mhinz/vim-startify'},
  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
  },

  -- Language
  {'ElmCast/elm-vim'},
  {'ap/vim-css-color'},
  {'leafgarland/typescript-vim'},
  {'moll/vim-node'},
  {'mxw/vim-jsx'},
  {'neovimhaskell/haskell-vim'},
  {'othree/javascript-libraries-syntax.vim'},
  {'pangloss/vim-javascript'},
  {'posva/vim-vue'},
  {'tpope/vim-markdown'},
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  {'tpope/vim-rails'},
  {'tpope/vim-bundler'},
  {'tpope/vim-rbenv'},
  {'tpope/vim-dadbod'},
  {'kristijanhusak/vim-dadbod-ui'},
  {'vim-ruby/vim-ruby'},
  {
    'fatih/vim-go',
    build = ':GoUpdateBinaries',
  },
  {'hashivim/vim-terraform'},

  -- Utilities
  {'Raimondi/delimitMate'},
  {'airblade/vim-gitgutter'},
  {'ZhiyuanLck/smart-pairs'},
  {'ludovicchabant/vim-gutentags'},
  {'ngmy/vim-rubocop'},
  {'tomtom/tcomment_vim'},
  {'tpope/vim-endwise'},
  {'tpope/vim-fugitive'},
  {'tpope/vim-rhubarb'},
  {'tpope/vim-repeat'},
  {'tpope/vim-surround'},
  {'tpope/vim-unimpaired'},
  {'andrewradev/splitjoin.vim'},
  {'dense-analysis/ale'},
  {'dbeniamine/cheat.sh-vim'},
  {
    'neoclide/coc.nvim',
    branch = 'release',
  },
  {'github/copilot.vim'},
  -- {
  --   'MeanderingProgrammer/render-markdown.nvim',
  --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  --   dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  --   ---@module 'render-markdown'
  --   ---@type render.md.UserConfig
  --   opts = {},
  -- },
}
