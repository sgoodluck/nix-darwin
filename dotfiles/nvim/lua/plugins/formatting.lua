-- Format-on-save via conform.nvim
-- Lazy-loads on BufWritePre so there is zero startup cost
-- Silent: no error notifications, no "no formatter found" warnings
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      nix        = { "nixfmt" },
      python     = { "black" },
      typescript = { "prettier" },
      javascript = { "prettier" },
      go         = { "gofmt" },
      rust       = { "rustfmt" },
      c          = { "clang_format" },
      cpp        = { "clang_format" },
      lua        = { "stylua" },
    },
    format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
    notify_on_error        = false,
    notify_no_formatters   = false,
  },
}
