-- Enable filetype detection, plugins, and indentation
vim.cmd('filetype plugin indent on')

-- Force sync syntax highlighting in those nasty, large .vue files
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.vue",
  command = "syntax sync fromstart"
})

-- Use bash aliases from noninteractive shell
vim.env.BASH_ENV = "~/dotfiles/.zsh_aliases"

-- Configuration
vim.opt.path = vim.env.PWD .. "/**"
vim.opt.number = true                    -- Shows line numbers
vim.opt.tabstop = 2                      -- Sets tabs to be two spaces
vim.opt.shiftwidth = 2                   -- Sets how many columns are indented when you re-indent
vim.opt.expandtab = true                 -- Expand tabs into spaces
vim.opt.autoindent = true                -- Enable auto-indent
vim.opt.smartindent = true               -- C-like autoindenting when starting a new line
vim.opt.mouse = "a"                      -- Enable mouse
vim.opt.swapfile = false                 -- Disables making temporary backup files (.swp)
vim.opt.autowrite = true                 -- Automatically :write before running commands
vim.opt.autoread = true                  -- Reload files changed outside vim
vim.opt.scrolloff = 8                    -- Start scrolling when we're 8 lines away from margins
vim.opt.sidescrolloff = 15
vim.opt.sidescroll = 1                   -- Auto resize Vim splits to active split
vim.opt.wildmenu = true                  -- Command line completion enhanced
vim.opt.wildignore:append("**/node_modules/**")
vim.opt.wildignore:append("**/bower_components/**")
vim.opt.wildignore:append("**/dump/**")
vim.opt.wildignore:append("*/.git/*,*/.hg/*,*/.svn/*")
vim.opt.backspace = "indent,eol,start"   -- Make backspace key work as expected
vim.opt.complete:remove("i")             -- Remove included files from auto completion
vim.opt.showmatch = true                 -- Brief visual feedback when you match a pair (ex. parentheses)
vim.opt.showmode = false                 -- Hide mode at bottom of the screen (since I use airline)
vim.opt.smarttab = true                  -- Tab smarter
vim.opt.nrformats:remove("octal")        -- Remove octals when using C-a or C-x
vim.opt.shiftround = true                -- Rounds indent to multiple of shiftwidth
vim.opt.ttimeout = true                  -- Timeout to wait for compound commands
vim.opt.ttimeoutlen = 50                 -- Sets timeout length for timeout commands
vim.opt.timeoutlen = 350
vim.opt.incsearch = true                 -- Show pattern matches as search is typed
vim.opt.laststatus = 2                   -- Always show a status line
vim.opt.ruler = false                    -- Hide col/line number (handled by airline)
vim.opt.showcmd = true                   -- Shows partial command in the last line
vim.opt.encoding = "utf-8"               -- Natch
vim.opt.list = true                      -- Show whitespace characters
vim.opt.listchars = "tab:▒░,trail:▓"
vim.opt.hlsearch = true                  -- Highlight previous search pattern
vim.opt.hidden = true                    -- Allows switching buffers without saving changes
vim.opt.backup = false                   -- Don't create backup files - live on the wild side
vim.opt.writebackup = false              -- Changes the save behavior of vim to write directly to buffer - danger is my middle name
vim.opt.fileformats = "unix,dos,mac"     -- Used of EOL formats
vim.opt.completeopt = "menuone,longest,preview" -- Options for insert mode completion
vim.opt.guioptions:remove("r")           -- Remove right-hand scrollbar
vim.opt.guioptions:remove("L")           -- Remove left-hand scrollbar
vim.opt.lazyredraw = true                -- Don't redraw sometimes
