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

-- Load Modus Vivendi Tinted colorscheme
local colors = {
  -- Base colors
  bg = "#1d2235",
  fg = "#ffffff",
  
  -- ANSI colors matching ghostty and zellij
  black = "#000000",
  red = "#ff5f59",
  green = "#44bc44",
  yellow = "#d0bc00",
  blue = "#2fafff",
  magenta = "#feacd0",
  cyan = "#00d3d0",
  white = "#ffffff",
  
  bright_black = "#1e1e1e",
  bright_red = "#ff9580",
  bright_green = "#70b900",
  bright_yellow = "#fec43f",
  bright_blue = "#79a8ff",
  bright_magenta = "#e5cfef",
  bright_cyan = "#00eff0",
  bright_white = "#989898",
  
  -- UI colors
  comment = "#a8a8a8",
  selection_bg = "#5a5a5a",
}

-- Apply colorscheme
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

-- Editor highlights
vim.api.nvim_set_hl(0, "Normal", { fg = colors.fg, bg = colors.bg })
vim.api.nvim_set_hl(0, "Comment", { fg = colors.comment, italic = true })
vim.api.nvim_set_hl(0, "Visual", { fg = colors.fg, bg = colors.selection_bg })
vim.api.nvim_set_hl(0, "Search", { fg = colors.bg, bg = colors.yellow })
vim.api.nvim_set_hl(0, "IncSearch", { fg = colors.bg, bg = colors.magenta })

-- Syntax highlights
vim.api.nvim_set_hl(0, "String", { fg = colors.green })
vim.api.nvim_set_hl(0, "Number", { fg = colors.cyan })
vim.api.nvim_set_hl(0, "Boolean", { fg = colors.cyan })
vim.api.nvim_set_hl(0, "Function", { fg = colors.blue })
vim.api.nvim_set_hl(0, "Keyword", { fg = colors.magenta })
vim.api.nvim_set_hl(0, "Type", { fg = colors.cyan })
vim.api.nvim_set_hl(0, "PreProc", { fg = colors.yellow })
vim.api.nvim_set_hl(0, "Special", { fg = colors.blue })
vim.api.nvim_set_hl(0, "Error", { fg = colors.red, bold = true })

-- Terminal colors
vim.g.terminal_color_0 = colors.black
vim.g.terminal_color_1 = colors.red
vim.g.terminal_color_2 = colors.green
vim.g.terminal_color_3 = colors.yellow
vim.g.terminal_color_4 = colors.blue
vim.g.terminal_color_5 = colors.magenta
vim.g.terminal_color_6 = colors.cyan
vim.g.terminal_color_7 = colors.white

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
