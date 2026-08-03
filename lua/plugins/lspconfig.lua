return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    inlay_hints = {
      enabled = true,
      exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
    },
    codelens = {
      enabled = true,
    },
    servers = {
      clangd = require("plugins.lsp.clangd"),
    },
  },
}
