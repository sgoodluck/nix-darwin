-- Treesitter: syntax highlighting, indentation, and incremental selection
-- branch="master" is required — the new "main" branch removed ensure_installed
-- event=BufReadPre/BufNewFile means 0ms startup cost; loads on first file open
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "nix", "python", "typescript", "go", "rust", "c",
        "lua", "markdown", "json", "yaml", "toml", "bash",
      },
      auto_install = false,
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
