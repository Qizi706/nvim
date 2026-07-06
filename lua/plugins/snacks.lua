---@module "snacks"

local dashboard = {
  glitch = nil,
  timer_id = nil,
}

function dashboard.calc_logo_width(logo)
  local lines = vim.split(logo, "\n", { plain = true })
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.api.nvim_strwidth(line))
  end
  return width
end

dashboard.logo = require("config.ui.ascii_arts").Tokamak.original
dashboard.logo_width = dashboard.calc_logo_width(dashboard.logo)

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

function dashboard.start_timer()
  dashboard.glitch = dashboard.glitch or require("config.ui.animation").glitch()
  dashboard.stop_timer()
  dashboard.timer_id = vim.fn.timer_start(32, function()
    local logo, color = dashboard.glitch()
    if color == 0 then
      vim.api.nvim_set_hl(0, "SnacksDashboardLogo", { fg = "#30D7FF" })
    elseif color == 1 then
      vim.api.nvim_set_hl(0, "SnacksDashboardLogo", { fg = "#FFC060" })
    else
      vim.api.nvim_set_hl(0, "SnacksDashboardLogo", { fg = "#3000FF" })
    end
    dashboard.logo = logo
    dashboard.logo_width = dashboard.calc_logo_width(logo)
    vim.api.nvim_exec_autocmds("User", { pattern = "SnacksDashboardUpdate", modeline = false })
  end, { ["repeat"] = -1 })
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

local function patch_zen_bufwinenter(win)
  local original_on = win.on

  win.on = function(self, event, cb, opts)
    if event == "BufWinEnter" then
      local original_cb = cb

      cb = function(...)
        local ok, ret = pcall(original_cb, ...)
        if ok then
          return ret
        end

        local err = tostring(ret)
        if err:find("snacks/zen.lua", 1, true) and err:find("Invalid buffer id", 1, true) then
          return
        end

        error(ret)
      end
    end

    return original_on(self, event, cb, opts)
  end
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "SnacksDashboardOpened",
      callback = dashboard.start_timer,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "SnacksDashboardClosed",
      callback = dashboard.stop_timer,
    })
  end,
  ---@type snacks.Config
  opts = {
    animate = { enabled = false },
    dashboard = dashboard_config,
    scroll = { enabled = false },
    indent = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    words = { enabled = true },
    terminal = { enabled = true },
    zen = {
      on_open = patch_zen_bufwinenter,
    },
  },
}
