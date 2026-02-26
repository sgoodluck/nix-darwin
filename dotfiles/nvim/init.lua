-- Leader must be set before lazy.nvim loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core config: no plugin dependencies
require("config.options")
require("config.keymaps")
require("config.autocmds")

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

-- Load plugins from lua/plugins/ (auto-scanned by lazy.nvim)
require("lazy").setup("plugins", {
  ui = { border = "rounded" },
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})
