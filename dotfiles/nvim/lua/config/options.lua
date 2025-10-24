-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable all cursor animations and blinking
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:block"
vim.opt.cursorline = false -- Disable cursor line highlighting
vim.opt.cursorcolumn = false -- Disable cursor column highlighting

-- Disable scrolling animations and smooth scrolling
vim.opt.scrolloff = 0 -- No scroll offset
vim.opt.sidescrolloff = 0 -- No horizontal scroll offset
vim.opt.smoothscroll = false -- Disable smooth scrolling

-- Disable other visual animations and effects
vim.opt.updatetime = 100 -- Reduce update time for snappier feel
vim.opt.timeoutlen = 300 -- Reduce timeout for faster key sequences
vim.opt.lazyredraw = true -- Disable redrawing during macro execution
vim.opt.ttyfast = true -- Fast terminal connection

-- Disable visual effects
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = false -- Disable relative line numbers (can cause visual noise)
vim.opt.signcolumn = "no" -- Hide sign column to reduce visual clutter
vim.opt.showmode = false -- Hide mode indicator
vim.opt.showcmd = false -- Hide command in status line

-- Disable window animations
vim.opt.splitbelow = true -- Split below instead of animated
vim.opt.splitright = true -- Split right instead of animated
vim.opt.equalalways = false -- Disable auto-resize animations

-- Disable search highlighting animations
vim.opt.hlsearch = false -- Disable search highlighting
vim.opt.incsearch = false -- Disable incremental search highlighting

-- Disable folding animations
vim.opt.foldenable = false -- Disable folding entirely
vim.opt.foldmethod = "manual" -- Manual folding only

-- Disable status line animations
vim.opt.laststatus = 0 -- Hide status line
vim.opt.ruler = false -- Hide ruler

-- Disable tab line animations
vim.opt.showtabline = 0 -- Hide tab line

-- Disable wild menu animations
vim.opt.wildmenu = false -- Disable wild menu
vim.opt.wildmode = "longest:full,full" -- Simple completion mode

-- Disable mouse animations
vim.opt.mouse = "" -- Disable mouse support entirely

-- Disable backup/swap file animations
vim.opt.backup = false -- Disable backup files
vim.opt.writebackup = false -- Disable write backup
vim.opt.swapfile = false -- Disable swap files
vim.opt.undofile = false -- Disable persistent undo

-- Disable bell and visual bell
vim.opt.belloff = "all" -- Disable all bells
vim.opt.visualbell = false -- Disable visual bell
vim.opt.errorbells = false -- Disable error bells