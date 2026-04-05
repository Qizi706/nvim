return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- LazyVim config for treesitter
    indent = { enable = true }, ---@type lazyvim.TSFeat
    highlight = { enable = true }, ---@type lazyvim.TSFeat
    folds = { enable = true }, ---@type lazyvim.TSFeat
    ensure_installed = {
      "bash",
      "c",
      "css",
      "diff",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "latex",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "norg",
      "printf",
      "python",
      "query",
      "regex",
      "scss",
      "svelte",
      "toml",
      "tsx",
      "typst",
      "typescript",
      "vim",
      "vimdoc",
      "vue",
      "xml",
      "yaml",
    },
  },
}
