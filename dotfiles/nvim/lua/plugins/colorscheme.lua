-- Colorscheme: modus_vivendi_tinted with background matched to terminal
-- lazy=false + priority=1000 ensures this loads before all other plugins
return {
  "miikanissi/modus-themes.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("modus-themes").setup({
      variant = "tinted",
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
      },
      on_colors = function(colors)
        colors.bg_main = "#1d2235"
      end,
    })
    vim.cmd("colorscheme modus_vivendi")
  end,
}
