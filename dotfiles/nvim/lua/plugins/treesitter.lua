-- Treesitter: syntax highlighting, indentation, and incremental selection
-- branch="master" is required — the new "main" branch removed ensure_installed
-- event=BufReadPre/BufNewFile means 0ms startup cost; loads on first file open
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  init = function()
    -- Fix: master branch queries reference "except*" node that the locked
    -- Python parser doesn't support. Patch the query file before first load.
    local qfile = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/queries/python/highlights.scm"
    local f = io.open(qfile, "r")
    if f then
      local content = f:read("*a")
      f:close()
      if content:find('"except%*"') then
        local patched = content:gsub('%s*"except%*"\n', "\n")
        local w = io.open(qfile, "w")
        if w then
          w:write(patched)
          w:close()
        end
      end
    end
  end,
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
