return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = {
          enabled = false,
        },
      },
      presets = {
        lsp_doc_border = true,
      },
      views = {
        hover = {
          win_options = {
            winblend = 0,
            winhighlight = {
              Normal = "NoiceLspDoc",
              FloatBorder = "NoiceLspDocBorder",
            },
          },
        },
      },
    },
  },
}
