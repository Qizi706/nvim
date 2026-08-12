return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.window = opts.window or {}
      opts.window.completion = opts.window.completion or {}
      opts.window.documentation = opts.window.documentation or {}

      opts.window.completion.winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None"
      opts.window.documentation.winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
    end,
  },
}
