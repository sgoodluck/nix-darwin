-- Completion engine: blink.cmp with lazydev.nvim for Neovim API awareness
-- lazydev: loads only for Lua files, provides vim.* completions via blink source
-- blink.cmp: Enter to accept, no ghost text inline preview, auto-show docs at 500ms
return {
  -- lazydev: Neovim API type definitions for Lua files
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- blink.cmp: fast completion engine with prebuilt Rust binary
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = { preset = "enter" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        ghost_text = { enabled = false },
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { "lazydev", "lsp", "path", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
