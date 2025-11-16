return {
  "snacks.nvim",
  opts = {
    dashboard = {
      formats = {
        key = function(item)
          return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
        end,
      },
      sections = {
        { section = "terminal", cmd = "fortune -s | cowsay", hl = "header", height = 11, padding = 1, indent = 8 },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
        -- {
        --   section = "terminal",
        --   cmd = "pokemon-colorscripts -b -r --no-title",
        --   hl = "header",
        --   height = 35,
        --   indent = 4,
        --   pane = 2,
        --   random = 10,
        -- },
      },
    },
  },
}
