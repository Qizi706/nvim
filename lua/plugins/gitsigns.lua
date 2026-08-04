return {
  "lewis6991/gitsigns.nvim",
  event = "LazyFile",
  opts = {
    current_line_blame_opts = { delay = 0 },
  },
  keys = {
    {
      "<leader>gt",
      function()
        Snacks.toggle({
          name = "Git Current Line Blame",
          get = function()
            return require("gitsigns.config").config.current_line_blame
          end,
          set = function(state)
            require("gitsigns").toggle_current_line_blame(state)
          end,
        }):toggle()
      end,
      desc = "Toggle Blame Line",
    },
  },
}
