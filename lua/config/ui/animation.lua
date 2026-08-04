local M = {}

M.signal = function()
  local art = require("config.ui.ascii_arts").Celeb
  local stages = {
    { ticks = 70 },
  }

  local function add_frame(frame, ticks)
    stages[#stages + 1] = { ticks = ticks or 3, frame = frame }
  end

  local function add_original(ticks)
    stages[#stages + 1] = { ticks = ticks }
  end

  -- Three ordered signal bursts keep the wordmark readable. Each burst grows
  -- and reconstructs through adjacent frames, then rests on the original mark
  -- before the next, stronger transformation begins.
  add_frame(1)
  add_frame(2, 4)
  add_frame(1)
  add_original(8)

  add_frame(2)
  add_frame(3)
  add_frame(4, 4)
  add_frame(3)
  add_frame(2)
  add_original(10)

  add_frame(3)
  add_frame(4)
  add_frame(5)
  add_frame(6, 6)
  add_frame(5)
  add_frame(4)
  add_frame(3)
  add_original(12)

  local current_stage = 1
  local counter = 0

  return function()
    local stage = stages[current_stage]
    local frame = stage.frame and art.frames[stage.frame] or nil
    local logo = frame and frame.logo or art.original
    local color = frame and frame.color or 0

    counter = counter + 1
    if counter >= stage.ticks then
      counter = 0
      current_stage = current_stage % #stages + 1
    end

    return logo, color
  end
end

return M
