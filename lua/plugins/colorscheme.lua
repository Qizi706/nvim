return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin/nvim",
    opts = {
      flavour = "mocha",
      transparent_background = false,
      auto_integrations = false,
      integrations = {
        dadbod_ui = true,
        dap = true,
        dap_ui = true,
        render_markdown = true,
        lualine = {
          mocha = function(colors)
            return {
              normal = {
                c = { bg = colors.base },
              },
              inactive = {
                a = { bg = colors.base },
                b = { bg = colors.base },
                c = { bg = colors.base },
              },
            }
          end,
        },
      },
      dim_inactive = {
        enable = false,
      },
      highlight_overrides = {
        mocha = function(colors)
          local float = { fg = colors.text, bg = colors.base }
          local border = { fg = colors.blue, bg = colors.base }

          return {
            -- Keep the editor and floating windows on one background without
            -- changing Catppuccin's semantic palette globally.
            NormalFloat = float,
            FloatBorder = border,
            FloatTitle = { fg = colors.blue, bg = colors.base, bold = true },
            FloatFooter = { fg = colors.overlay1, bg = colors.base },
            Pmenu = float,
            PmenuSel = { fg = colors.text, bg = colors.surface0, bold = true },
            PmenuKind = { fg = colors.blue, bg = colors.base },
            PmenuExtra = { fg = colors.overlay1, bg = colors.base },
            PmenuSbar = { bg = colors.base },
            PmenuThumb = { bg = colors.surface1 },
            StatusLine = { fg = colors.text, bg = colors.base },
            StatusLineNC = { fg = colors.overlay0, bg = colors.base },

            -- Noice 接管的 LSP hover/signature 文档窗口。
            NoiceLspDoc = { fg = colors.text, bg = colors.base, blend = 0 },
            NoiceLspDocBorder = { fg = colors.blue, bg = colors.base, blend = 0 },

            -- Snacks Picker creates a separate highlight group for every pane.
            SnacksPicker = float,
            SnacksPickerInput = float,
            SnacksPickerList = float,
            SnacksPickerPreview = float,
            SnacksPickerBox = float,

            SnacksPickerBorder = border,
            SnacksPickerInputBorder = border,
            SnacksPickerListBorder = border,
            SnacksPickerPreviewBorder = border,
            SnacksPickerBoxBorder = border,

            SnacksPickerTitle = { fg = colors.blue, bg = colors.base, bold = true },
            SnacksPickerInputTitle = { fg = colors.blue, bg = colors.base, bold = true },
            SnacksPickerListTitle = { fg = colors.blue, bg = colors.base, bold = true },
            SnacksPickerPreviewTitle = { fg = colors.blue, bg = colors.base, bold = true },
            SnacksPickerBoxTitle = { fg = colors.blue, bg = colors.base, bold = true },
            SnacksPickerSelected = { fg = colors.text, bg = colors.surface0, bold = true },
            SnacksPickerListCursorLine = { bg = colors.surface0 },

            -- WhichKey uses its own window-local aliases instead of directly
            -- using NormalFloat and FloatBorder.
            WhichKeyNormal = float,
            WhichKeyBorder = border,
            WhichKeyTitle = { fg = colors.blue, bg = colors.base, bold = true },
          }
        end,
      },
    },
  },
}
