return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  enabled = true,
  init = false,
  opts = function()
    local dashboard = require("alpha.themes.dashboard")
    local logo = require("global.ui.ascii_arts").Tokamak.original
    dashboard.section.header.val = vim.split(logo, "\n")
    dashboard.section.buttons.val = {
      dashboard.button("f", " " .. " Find file", "<cmd> lua LazyVim.pick()() <cr>"),
      dashboard.button("n", " " .. " New file", [[<cmd> ene <BAR> startinsert <cr>]]),
      dashboard.button("r", " " .. " Recent files", [[<cmd> lua LazyVim.pick("oldfiles")() <cr>]]),
      dashboard.button("g", " " .. " Find text", [[<cmd> lua LazyVim.pick("live_grep")() <cr>]]),
      dashboard.button("c", " " .. " Config", "<cmd> lua LazyVim.pick.config_files()() <cr>"),
      dashboard.button("s", " " .. " Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
      dashboard.button("x", " " .. " Lazy Extras", "<cmd> LazyExtras <cr>"),
      dashboard.button("l", "󰒲 " .. " Lazy", "<cmd> Lazy <cr>"),
      dashboard.button("q", " " .. " Quit", "<cmd> qa <cr>"),
    }
    vim.cmd([[ highlight AlphaLogo guifg=#30D7FF ]])
    vim.cmd([[ highlight AlphaText guifg=#1FB7E0 ]])
    dashboard.section.header.opts.hl = "AlphaLogo"
    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = "AlphaText"
      button.opts.hl_shortcut = "AlphaText"
    end
    dashboard.section.footer.opts.hl = "AlphaText"
    dashboard.opts.layout[1].val = 5
    dashboard.opts.layout[3].val = 3
    table.insert(dashboard.opts.layout, 5, { type = "padding", val = 2 })

    return dashboard
  end,
  config = function(_, dashboard)
    -- 1. 处理 Lazy 加载时的清理逻辑
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "AlphaReady",
        callback = function()
          require("lazy").show()
        end,
      })
    end

    require("alpha").setup(dashboard.opts)

    -- 2. 底部状态栏显示
    vim.api.nvim_create_autocmd("User", {
      once = true,
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        dashboard.section.footer.val = "  Neovim loaded "
          .. stats.loaded
          .. "/"
          .. stats.count
          .. " plugins in "
          .. ms
          .. "ms"
        pcall(vim.cmd.AlphaRedraw)
      end,
    })

    -- =======================================================
    -- 3. 修改：封装动画启动和停止函数
    -- =======================================================

    -- 定义：停止动画
    local function stop_glitch()
      if vim.g.alphatimer then
        vim.fn.timer_stop(vim.g.alphatimer)
        vim.g.alphatimer = nil
      end
    end

    -- 定义：启动动画
    local function start_glitch()
      -- 安全检查：防止重复启动导致多个定时器叠加
      stop_glitch()

      local glitch = require("global.ui.animation").glitch()

      -- 启动定时器
      vim.g.alphatimer = vim.fn.timer_start(30, function()
        -- 获取当前光标位置，防止重绘导致光标跳动
        local curpos = vim.api.nvim_win_get_cursor(0)

        local logo, color = glitch()
        if color == 0 then
          vim.cmd([[ highlight AlphaLogo guifg=#30D7FF ]])
        elseif color == 1 then
          vim.cmd([[ highlight AlphaLogo guifg=#FFC070 ]])
        else
          vim.cmd([[ highlight AlphaLogo guifg=#3000FF ]])
        end

        dashboard.section.header.val = vim.split(logo, "\n")
        pcall(vim.cmd.AlphaRedraw)

        -- 恢复光标位置
        pcall(vim.api.nvim_win_set_cursor, 0, curpos)
      end, { ["repeat"] = -1 })
    end

    -- =======================================================
    -- 4. 注册自动命令：控制何时启停
    -- =======================================================

    -- 场景 A: 首次加载 AlphaReady 时 -> 启动
    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      callback = start_glitch,
    })

    -- 场景 B: 从其他文件切回 Alpha 界面 (BufEnter) -> 启动
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*",
      callback = function()
        if vim.bo.filetype == "alpha" then
          start_glitch()
        end
      end,
    })

    -- 场景 C: 离开 Alpha 去写代码 (BufLeave) -> 停止
    vim.api.nvim_create_autocmd("BufLeave", {
      pattern = "*",
      callback = function()
        if vim.bo.filetype == "alpha" then
          stop_glitch()
        end
      end,
    })
  end,
}
