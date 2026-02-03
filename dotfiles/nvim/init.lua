-- Minimal Neovim Configuration
-- Add plugins incrementally as you need them

-- Leader key
vim.g.mapleader = " "

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.termguicolors = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250

-- Basic keymaps
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Modus Vivendi Tinted colorscheme (matching terminal)
local colors = {
  bg = "#1d2235",
  fg = "#ffffff",
  comment = "#a8a8a8",
  selection_bg = "#5a5a5a",
  black = "#000000",
  red = "#ff5f59",
  green = "#44bc44",
  yellow = "#d0bc00",
  blue = "#2fafff",
  magenta = "#feacd0",
  cyan = "#00d3d0",
  white = "#ffffff",
}

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end

-- Apply colorscheme
vim.api.nvim_set_hl(0, "Normal", { fg = colors.fg, bg = colors.bg })
vim.api.nvim_set_hl(0, "Comment", { fg = colors.comment, italic = true })
vim.api.nvim_set_hl(0, "Visual", { fg = colors.fg, bg = colors.selection_bg })
vim.api.nvim_set_hl(0, "Search", { fg = colors.bg, bg = colors.yellow })
vim.api.nvim_set_hl(0, "IncSearch", { fg = colors.bg, bg = colors.magenta })
vim.api.nvim_set_hl(0, "String", { fg = colors.green })
vim.api.nvim_set_hl(0, "Number", { fg = colors.cyan })
vim.api.nvim_set_hl(0, "Boolean", { fg = colors.cyan })
vim.api.nvim_set_hl(0, "Function", { fg = colors.blue })
vim.api.nvim_set_hl(0, "Keyword", { fg = colors.magenta })
vim.api.nvim_set_hl(0, "Type", { fg = colors.cyan })
vim.api.nvim_set_hl(0, "PreProc", { fg = colors.yellow })
vim.api.nvim_set_hl(0, "Special", { fg = colors.blue })
vim.api.nvim_set_hl(0, "Error", { fg = colors.red, bold = true })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require("lazy").setup({
  -- fzf for fuzzy finding
  {
    "junegunn/fzf",
    build = "./install --bin",
  },
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    keys = {
      { "<leader>ff", "<cmd>Files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Rg<cr>", desc = "Find text" },
      { "<leader>fb", "<cmd>Buffers<cr>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>History<cr>", desc = "Recent files" },
    },
  },

  -- Telescope (required by commander)
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
  },

  -- Commander (Spacemacs-like command palette)
  {
    "FeiyouG/commander.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader><space>", "<cmd>Telescope commander<cr>", desc = "Commander" },
      { "<leader>?", "<cmd>Telescope commander<cr>", desc = "Show commands" },
    },
    config = function()
      require("commander").setup({
        components = { "DESC", "KEYS", "CAT" },
        sort_by = { "DESC", "KEYS", "CAT", "CMD" },
        integration = {
          telescope = { enable = true },
          lazy = { enable = true },
        }
      })

      -- Register commands
      require("commander").add({
        { desc = "Find files", cmd = "<cmd>Files<cr>", keys = { "n", "<leader>ff" }, cat = "files" },
        { desc = "Find text", cmd = "<cmd>Rg<cr>", keys = { "n", "<leader>fg" }, cat = "files" },
        { desc = "Find buffers", cmd = "<cmd>Buffers<cr>", keys = { "n", "<leader>fb" }, cat = "files" },
        { desc = "Recent files", cmd = "<cmd>History<cr>", keys = { "n", "<leader>fh" }, cat = "files" },
        { desc = "Save file", cmd = "<cmd>w<cr>", keys = { "n", "<leader>w" }, cat = "edit" },
        { desc = "Quit", cmd = "<cmd>q<cr>", keys = { "n", "<leader>q" }, cat = "edit" },
        { desc = "File explorer", cmd = "<cmd>Ex<cr>", keys = { "n", "-" }, cat = "files" },
      })
    end,
  },
}, {
  ui = { border = "rounded" },
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})

-- File explorer shortcut
vim.keymap.set("n", "-", ":Ex<CR>", { desc = "File explorer" })
