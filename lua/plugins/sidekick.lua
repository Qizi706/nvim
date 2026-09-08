local refresh_state = setmetatable({}, { __mode = "k" })

local function refresh_scrollback(terminal, captured)
  local sb = terminal.scrollback
  if not (sb and sb:is_open()) then
    return
  end

  local win = terminal.win
  if not (win and vim.api.nvim_win_is_valid(win)) then
    return
  end

  local state = refresh_state[terminal] or {}
  refresh_state[terminal] = state
  if state.refreshing then
    return
  end
  state.refreshing = true

  local view = vim.api.nvim_win_call(win, function()
    return vim.fn.winsaveview()
  end)

  -- The snapshot is a non-modifiable terminal buffer. Replace it between
  -- event-loop ticks instead of trying to update it in place.
  sb.closing = true
  vim.schedule(function()
    if not (vim.api.nvim_win_is_valid(win) and sb:is_open()) then
      sb.closing = false
      state.refreshing = false
      return
    end

    sb:close()
    vim.schedule(function()
      if not vim.api.nvim_win_is_valid(win) then
        sb.closing = false
        state.refreshing = false
        return
      end

      sb:open()
      vim.api.nvim_win_call(win, function()
        vim.fn.winrestview(view)
      end)
      state.last_dump = captured
      sb.closing = false
      state.refreshing = false
    end)
  end)
end


return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      mux = {
        enabled = true,
        backend = "tmux",
        create = "terminal",
      },
      tools = {
        -- codex = { is_proc = false },
        coco = { cmd = { "coco" } },
        traex = { cmd = { "traex" } },
      },
      prompts = {
        -- Global prompts
        chinese = "本次对话请使用中文回复。",
        concise = "本次对话请简洁作答，先给结论，必要时再补充细节。",
        detailed = "本次对话请适当详细说明推理、权衡和实现细节，但避免无关展开。",
        no_modify = "本次对话中，除非我明确要求，否则不要修改文件或直接进行代码改动。",
        ask_first = "本次对话中，如有不明确的需求、意图或边界，请先向我确认，不要自行假设。",
        -- One-shot prompts
        web_search = "对于后续内容，请先进行联网搜索，再结合搜索结果作答。",
        translate = "对于后续内容，请翻译成自然、准确的中文。",
        redo = "请根据刚才已明确的讨论，重新执行上一版修改。",
        codegraph_review = [[审查当前未提交修改。只报告本次修改引入的、可操作的正确性问题，不修改文件。
          必须使用 CodeGraph：
          1. 从 diff 提取有行为变化的关键函数、方法、类型和文件。
          2. 对关键符号优先使用 codegraph node、callers、callees。
          3. 对可能跨模块传播的变化使用 codegraph impact --depth 2。
          4. 使用 codegraph affected 查找可能受影响但未覆盖的测试。
          5. 如果调用经过接口、虚函数或回调，使用 codegraph explore 追踪实际候选路径。
          6. CodeGraph 只用于定位和建立关系；最终结论必须用当前源码、diff 或测试验证。

          重点检查：
          - 错误处理、返回值和资源生命周期
          - 并发、锁顺序、异步回调及对象生命周期
          - 边界值、空值、溢出和错误路径
          - API/ABI、配置和协议兼容性
          - 调用方是否仍满足被修改函数的新前置条件
          - 测试是否覆盖受影响路径

          输出要求：
          - findings 按严重程度排序
          - 每条包含准确文件和行号
          - 说明触发条件、调用路径和实际后果
          - 不报告纯风格问题
          - 没有发现时明确说明 no findings
          '
        ]],
      },
      win = {
        config = function(terminal)
          terminal.opts.split.width = 0.4
          -- if terminal.tool.name == "codex" then
          --   terminal.opts.split.width = 0.4
          -- elseif terminal.tool.name == "coco" then
          --   terminal.opts.split.width = 0.4
          -- elseif terminal.tool.name == "traex" then
          --   terminal.opts.split.width = 0.4
          -- end
        end,
        keys = {
          prompt = false,
          refresh_scrollback = {
            "R",
            function(t)
              refresh_scrollback(t)
            end,
            mode = "n",
            desc = "Refresh tmux scrollback",
          },
        },
      },
    },
    nes = { enabled = false },
    copilot = {
      -- track copilot's status with `didChangeStatus`
      status = {
        enabled = false,
        level = vim.log.levels.WARN,
        -- set to vim.log.levels.OFF to disable notifications
        -- level = vim.log.levels.OFF,
      },
    },
  },
}
