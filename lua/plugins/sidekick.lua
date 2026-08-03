return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      mux = {
        enabled = true,
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
          -- if terminal.tool.name == "codex" then
          --   terminal.opts.split.width = 0.4
          -- elseif terminal.tool.name == "coco" then
          --   terminal.opts.split.width = 0.4
          -- elseif terminal.tool.name == "traex" then
          --   terminal.opts.split.width = 0.4
          -- end
        end,
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
  keys = {
    {
      "<c-.>",
      function()
        require("sidekick.cli").focus()
      end,
      desc = "Sidekick Focus",
      mode = { "n", "t", "i", "x" },
    },
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Sidekick Toggle CLI",
    },
    {
      "<leader>as",
      function()
        require("sidekick.cli").select()
      end,
      -- Or to select only installed tools:
      -- require("sidekick.cli").select({ filter = { installed = true } })
      desc = "Select CLI",
    },
    {
      "<leader>ad",
      function()
        require("sidekick.cli").close()
      end,
      desc = "Detach a CLI Session",
    },
    {
      "<leader>at",
      function()
        require("sidekick.cli").send({ msg = "{this}" })
      end,
      mode = { "x", "n" },
      desc = "Send This",
    },
    {
      "<leader>af",
      function()
        require("sidekick.cli").send({ msg = "{file}" })
      end,
      desc = "Send File",
    },
    {
      "<leader>av",
      function()
        require("sidekick.cli").send({ msg = "{selection}" })
      end,
      mode = { "x" },
      desc = "Send Visual Selection",
    },
    {
      "<leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      mode = { "n", "x" },
      desc = "Sidekick Select Prompt",
    },
    -- Example of a keybinding to open Claude directly
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle({ name = "claude", focus = true })
      end,
      desc = "Sidekick Toggle Claude",
    },
  },
}
