-- Basic Neovim configuration

-- General settings
vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = true      -- Show relative line numbers
vim.opt.tabstop = 2                -- Number of spaces tabs count for
vim.opt.shiftwidth = 2             -- Size of an indent
vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.smartindent = true         -- Insert indents automatically
vim.opt.wrap = false               -- Disable line wrap
vim.opt.ignorecase = true          -- Ignore case when searching
vim.opt.smartcase = true           -- Override ignorecase if search has capitals
vim.opt.hlsearch = true            -- Highlight search results
vim.opt.termguicolors = true       -- True color support
vim.opt.mouse = 'a'                -- Enable mouse support
vim.opt.clipboard = 'unnamedplus'  -- Use system clipboard
vim.opt.swapfile = false           -- Don't create swapfiles

-- Set leader key to space
vim.g.mapleader = " "

-- Basic key mappings
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Basic window management
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split horizontally" })

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and stay in visual mode" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and stay in visual mode" })
