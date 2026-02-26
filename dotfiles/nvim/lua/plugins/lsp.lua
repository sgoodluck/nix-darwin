-- LSP configuration using native Neovim 0.11 API (vim.lsp.config/enable)
-- nvim-lspconfig is installed ONLY for its lsp/ server definitions -- no require('lspconfig')
-- blink.cmp capabilities are passed to all servers via vim.lsp.config("*", ...)
return {
  "neovim/nvim-lspconfig",
  dependencies = { "saghen/blink.cmp" },
  config = function()
    -- Share blink.cmp capabilities with all LSP servers
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    vim.lsp.config("*", { capabilities = capabilities })

    -- lua_ls: teach it about the Neovim API and LuaJIT runtime
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })

    -- Enable all 7 target language servers
    vim.lsp.enable({ "nixd", "pyright", "ts_ls", "gopls", "rust_analyzer", "ccls", "lua_ls" })

    -- Buffer-local LSP keymaps: only active when a server attaches
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
      callback = function(event)
        local buf = event.buf
        local map = function(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = buf, desc = desc })
        end

        map("gd",          vim.lsp.buf.definition,                                       "Go to definition")
        map("gr",          vim.lsp.buf.references,                                       "References")
        map("K",           vim.lsp.buf.hover,                                            "Hover documentation")
        map("<leader>la",  vim.lsp.buf.code_action,                                      "Code action")
        map("<leader>lr",  vim.lsp.buf.rename,                                           "Rename symbol")
        map("<leader>lf",  function() require("conform").format({ bufnr = buf }) end,    "Format buffer")
        map("<leader>ld",  vim.diagnostic.open_float,                                    "Line diagnostic")
        map("<leader>lD",  vim.diagnostic.setloclist,                                    "Diagnostic list")
      end,
    })

    -- Diagnostic display: virtual text for warnings+, nerd font icons in gutter
    vim.diagnostic.config({
      virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
        prefix = "●",
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN]  = " ",
          [vim.diagnostic.severity.INFO]  = " ",
          [vim.diagnostic.severity.HINT]  = "󰌵 ",
        },
      },
      underline          = true,
      update_in_insert   = false,
      severity_sort      = true,
    })
  end,
}
