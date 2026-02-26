return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "FzfLua",
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live grep" },
    { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
    { "<leader>fc", "<cmd>FzfLua keymaps<CR>", desc = "Keymaps (command palette)" },
  },
  opts = {
    winopts = {
      width = 0.8,
      height = 0.8,
      row = 0.5,
      col = 0.5,
      border = "rounded",
      preview = {
        layout = "horizontal",
        horizontal = "right:50%",
      },
    },
  },
}
