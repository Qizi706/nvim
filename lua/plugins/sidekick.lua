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

local function auto_refresh_scrollback(terminal)
  local timer = assert(vim.uv.new_timer())
  local state = refresh_state[terminal] or {}
  refresh_state[terminal] = state

  timer:start(750, 750, function()
    vim.schedule(function()
      if terminal.closed then
        if not timer:is_closing() then
          timer:stop()
          timer:close()
        end
        return
      end

      local sb = terminal.scrollback
      if not (sb and sb:is_open()) or state.refreshing then
        state.last_dump = nil
        return
      end

      local text = terminal.parent and terminal.parent:dump() or nil
      if not text then
        return
      end
      if state.last_dump == nil then
        state.last_dump = text
      elseif text ~= state.last_dump then
        refresh_scrollback(terminal, text)
      end
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
      },
      win = {
        config = function(terminal)
          terminal.opts.split.width = 0.4
          -- auto_refresh_scrollback(terminal)

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
