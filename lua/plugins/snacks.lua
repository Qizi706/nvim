---@module "snacks"

local dashboard = {
  animation = nil,
  timer_id = nil,
  nvim_focused = true,
  logo_color = nil,
  animation_colors = nil,
}

function dashboard.calc_logo_width(logo)
  local lines = vim.split(logo, "\n", { plain = true })
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.api.nvim_strwidth(line))
  end
  return width
end

dashboard.logo = require("config.ui.ascii_arts").Celeb.original
dashboard.logo_width = dashboard.calc_logo_width(dashboard.logo)

function dashboard.get_animation_colors()
  if dashboard.animation_colors ~= nil then
    return dashboard.animation_colors
  end

  local ok, palette = pcall(function()
    return require("catppuccin.palettes").get_palette("mocha")
  end)

  -- Keep the animation usable while Catppuccin is unavailable or still loading.
  palette = ok and palette or {
    sky = "#89dceb",
    peach = "#fab387",
    mauve = "#cba6f7",
  }
  dashboard.animation_colors = {
    [0] = palette.sky,
    [1] = palette.peach,
    [2] = palette.mauve,
  }

  return dashboard.animation_colors
end

function dashboard.header()
  return {
    text = {
      { dashboard.logo, hl = "SnacksDashboardLogo", width = dashboard.logo_width },
    },
    align = "center",
    padding = 3,
  }
end

function dashboard.stop_timer()
  if dashboard.timer_id ~= nil then
    vim.fn.timer_stop(dashboard.timer_id)
    dashboard.timer_id = nil
  end
end

function dashboard.is_focused()
  local win = vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win)
  return vim.bo[buf].filetype == "snacks_dashboard"
end

function dashboard.start_timer()
  if dashboard.timer_id ~= nil then
    return
  end

  dashboard.animation = dashboard.animation or require("config.ui.animation").signal()
  dashboard.timer_id = vim.fn.timer_start(32, function()
    local logo, color = dashboard.animation()

    local logo_changed = logo ~= dashboard.logo
    local color_changed = color ~= dashboard.logo_color

    -- 静止帧不再触发重绘
    if not logo_changed and not color_changed then
      return
    end

    if color_changed then
      local colors = dashboard.get_animation_colors()

      vim.api.nvim_set_hl(0, "SnacksDashboardLogo", {
        fg = colors[color],
      })
      dashboard.logo_color = color
    end

    if logo_changed then
      dashboard.logo = logo
      dashboard.logo_width = dashboard.calc_logo_width(logo)
    end

    vim.api.nvim_exec_autocmds("User", {
      pattern = "SnacksDashboardUpdate",
      modeline = false,
    })
  end, { ["repeat"] = -1 })
end

function dashboard.update_timer()
  if dashboard.nvim_focused and dashboard.is_focused() then
    dashboard.start_timer()
  else
    dashboard.stop_timer()
  end
end

local dashboard_config = {
  enabled = true,
  width = 60,
  sections = {
    dashboard.header,
    { section = "keys", gap = 1, padding = 4 },
    { section = "startup", icon = "  " },
  },
}

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  init = function()
    if vim.env.TMUX then
      local ok, extended_keys = pcall(vim.fn.system, { "tmux", "show", "-g", "extended-keys" })
      local setting = ok and vim.trim(extended_keys):match("(%S+)$") or nil

      -- Snacks only handles `extended-keys on` upstream. `always` has the same
      -- TermResponse leakage, so resolve the client terminal without probing it.
      if setting == "on" or setting == "always" then
        local term_ok, terminal_name = pcall(
          vim.fn.system,
          { "tmux", "display-message", "-p", "#{client_termname}" }
        )
        terminal_name = term_ok and vim.trim(terminal_name):gsub("^xterm%-", "") or ""

        if terminal_name ~= "" then
          require("snacks.image.terminal")._terminal = {
            terminal = terminal_name,
            version = "",
            pending = nil,
          }
        end
      end
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "SnacksDashboardOpened",
      callback = dashboard.update_timer,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "SnacksDashboardClosed",
      callback = dashboard.stop_timer,
    })

    vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "WinLeave", "BufWinLeave" }, {
      callback = vim.schedule_wrap(dashboard.update_timer),
    })

    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function()
        dashboard.nvim_focused = true
        dashboard.update_timer()
      end,
    })

    vim.api.nvim_create_autocmd("FocusLost", {
      callback = function()
        dashboard.nvim_focused = false
        dashboard.stop_timer()
      end,
    })
  end,
  ---@type snacks.Config
  opts = {
    animate = { enabled = false },
    dashboard = dashboard_config,
    picker = {
      layouts = {
        default = {
          layout = {
            backdrop = false,
          },
        },
      },
    },
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = false,
        float = true,
        max_width = 80,
        max_height = 30,
      },
      math = {
        enabled = true,
      },
    },
    scroll = { enabled = false },
    indent = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    words = { enabled = true },
    terminal = { enabled = true },
  },
}
