return {
  "lewis6991/gitsigns.nvim",
  event = "BufReadPre",
  opts = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "-" },
      topdelete = { text = "-" },
      changedelete = { text = "~" },
      untracked = { text = "?" },
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]h", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next hunk")

      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[h", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Prev hunk")

      map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
      map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
    end,
  },
}
