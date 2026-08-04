local M = {}

local width = 54
local height = 11

local function pad(line)
  local padding = width - vim.fn.strchars(line)
  assert(padding >= 0, "CELEB logo line exceeds its configured width")
  return line .. string.rep(" ", padding)
end

local function render(lines)
  return "\n\n" .. table.concat(lines, "\n") .. "\n"
end

local function round(value)
  if value < 0 then
    return math.ceil(value - 0.5)
  end
  return math.floor(value + 0.5)
end

local function blank_matrix()
  local matrix = {}
  for y = 1, height do
    matrix[y] = {}
    for x = 1, width do
      matrix[y][x] = " "
    end
  end
  return matrix
end

local function to_matrix(lines)
  local matrix = blank_matrix()
  for y, line in ipairs(lines) do
    for x = 1, width do
      matrix[y][x] = vim.fn.strcharpart(line, x - 1, 1)
    end
  end
  return matrix
end

local function to_lines(matrix)
  local lines = {}
  for y = 1, height do
    lines[y] = table.concat(matrix[y])
  end
  return lines
end

local function inside(region, x, y)
  return x >= region.x1 and x <= region.x2 and y >= region.y1 and y <= region.y2
end

local function draw(matrix, x, y, char, overwrite)
  if char == " " or x < 1 or x > width or y < 1 or y > height then
    return
  end
  if overwrite or matrix[y][x] == " " then
    matrix[y][x] = char
  end
end

local function circuit_rail(edge_left, fill, node, core, edge_right)
  return edge_left .. fill:rep(7) .. node .. fill:rep(7) .. core .. fill:rep(8) .. node .. fill:rep(7) .. edge_right
end

-- An original forward-leaning CELEB wordmark with clipped terminals,
-- asymmetric crossbars, and angular counters, rendered as Unicode Braille.
-- The rails keep the silhouette balanced while also suggesting a data bus.
local base = {
  circuit_rail("⠐", "⠒", "⠲⣶⠶⠶⠶⣶⠖", "⠲⣶⠶⠶⠶⠶⠶⣶⠖", "⠂"),
  "    ⣠⣴⣿⢿⣷⣶⣦⡄ ⢀⣴⣿⠿⠿⠿⠿⠿⠿⠇ ⢀⣴⣿⠇      ⢀⣴⣿⠿⠿⠿⠿⠿⠿⠇ ⢰⣶⣶⣶⣶⣶⣦⡀",
  "  ⢀⣼⣿⠋⠁⢰⣿⠿⠋⠁ ⣸⣿⠁        ⣿⡟⠁       ⣸⣿⠁        ⣾⡿   ⠈⢿⣷",
  "  ⣾⡿⠁        ⣿⡏        ⢸⣿⠃        ⣿⡏         ⣿⡇    ⢸⣿",
  " ⢰⣿⠇        ⢰⣿⣇⣀⣀⣀⣀⣀   ⢸⣿        ⢰⣿⣇⣀⣀⣀⣀⣀   ⢰⣿⣇⣀⣀⣠⣶⣿⠟",
  " ⢸⣿         ⢸⣿⠛⠛⠛⣿⣿⠟   ⣿⡟        ⢸⣿⠛⠛⠛⣿⣿⠟   ⢸⣿⠛⠛⠛⠛⢿⣷⡀",
  " ⣿⡟         ⣿⡟   ⠉⠁    ⣿⡇        ⣿⡟   ⠉⠁    ⣿⡟    ⠈⣻⣿",
  " ⢿⣷   ⢀⣀   ⢠⣿⡇        ⢸⣿⠃       ⢠⣿⡇         ⣿⡇    ⢀⣿⡏",
  " ⠘⣿⣧⣀⣀⣘⣿⣧  ⢸⣿⣄        ⠸⣿⣦   ⣿⣧  ⢸⣿⣄        ⢸⣿⣃⣀⣀⣀⣴⣿⠟⠁",
  "  ⠈⠛⠿⠿⠛⠛⠉   ⠙⠿⠿⠿⠿⠿⠿⠿⠇  ⠘⠿⠿⠿⠿⠿⠿⠇  ⠙⠿⠿⠿⠿⠿⠿⠿⠇ ⠘⠛⠛⠛⠛⠛⠛⠁",
  circuit_rail("⠠", "⠤", "⠴⣿⣤⣤⣤⣿⠦", "⠴⣿⣤⣤⣤⣤⣤⣿⠦", "⠄"),
}

for index, line in ipairs(base) do
  base[index] = pad(line)
end

assert(#base == height, "CELEB logo height does not match its matrix")

-- Each stage applies an affine warp to the complete matrix first, then moves
-- overlapping rectangular layers independently. Overlapping layers accumulate
-- their displacement, which makes the core break away from both its row and
-- column instead of behaving like a collection of horizontally shifted lines.
local fracture_levels = {
  {
    color = 0,
    skew_x = 0.12,
    skew_y = 0,
    layers = {
      { x1 = 20, x2 = 37, y1 = 4, y2 = 8, dx = 1, dy = 0 },
    },
    ghosts = {
      { x1 = 20, x2 = 37, y1 = 4, y2 = 8, dx = -2, dy = 0, stride = 9, phase = 0 },
    },
  },
  {
    color = 0,
    skew_x = -0.22,
    skew_y = 0.025,
    scan = { period = 4, phase = 1, dx = 1 },
    layers = {
      { x1 = 1, x2 = 19, y1 = 2, y2 = 10, dx = -1, dy = 1 },
      { x1 = 18, x2 = 39, y1 = 4, y2 = 8, dx = 2, dy = -1 },
      { x1 = 40, x2 = 54, y1 = 2, y2 = 10, dx = 1, dy = 0 },
    },
    ghosts = {
      { x1 = 18, x2 = 39, y1 = 4, y2 = 8, dx = -3, dy = 1, stride = 7, phase = 2 },
    },
  },
  {
    color = 1,
    skew_x = 0.35,
    skew_y = -0.035,
    scan = { period = 3, phase = 0, dx = -1 },
    layers = {
      { x1 = 1, x2 = 54, y1 = 1, y2 = 5, dx = 2, dy = 1 },
      { x1 = 1, x2 = 54, y1 = 7, y2 = 11, dx = -2, dy = -1 },
      { x1 = 17, x2 = 40, y1 = 3, y2 = 9, dx = 2, dy = 0 },
    },
    ghosts = {
      { x1 = 1, x2 = 54, y1 = 1, y2 = 11, dx = -2, dy = 0, stride = 11, phase = 3 },
    },
  },
  {
    color = 1,
    skew_x = -0.5,
    skew_y = 0.045,
    scan = { period = 3, phase = 1, dx = 2 },
    layers = {
      { x1 = 1, x2 = 18, y1 = 1, y2 = 11, dx = -2, dy = -1 },
      { x1 = 18, x2 = 38, y1 = 2, y2 = 10, dx = 3, dy = 1 },
      { x1 = 37, x2 = 54, y1 = 1, y2 = 11, dx = -1, dy = 1 },
      { x1 = 23, x2 = 33, y1 = 4, y2 = 8, dx = -2, dy = -1 },
    },
    ghosts = {
      { x1 = 1, x2 = 18, y1 = 1, y2 = 11, dx = 4, dy = 1, stride = 8, phase = 1 },
      { x1 = 37, x2 = 54, y1 = 1, y2 = 11, dx = -4, dy = -1, stride = 8, phase = 4 },
    },
  },
  {
    color = 2,
    skew_x = 0.65,
    skew_y = -0.06,
    scan = { period = 2, phase = 0, dx = -2 },
    layers = {
      { x1 = 1, x2 = 27, y1 = 1, y2 = 6, dx = -3, dy = 1 },
      { x1 = 28, x2 = 54, y1 = 1, y2 = 6, dx = 3, dy = -1 },
      { x1 = 1, x2 = 27, y1 = 7, y2 = 11, dx = 3, dy = -2 },
      { x1 = 28, x2 = 54, y1 = 7, y2 = 11, dx = -3, dy = 2 },
      { x1 = 19, x2 = 38, y1 = 3, y2 = 9, dx = 2, dy = -1 },
    },
    ghosts = {
      { x1 = 1, x2 = 54, y1 = 1, y2 = 11, dx = 5, dy = 0, stride = 7, phase = 0 },
      { x1 = 1, x2 = 54, y1 = 1, y2 = 11, dx = -5, dy = 0, stride = 9, phase = 4 },
    },
  },
  {
    color = 2,
    skew_x = -0.85,
    skew_y = 0.08,
    scan = { period = 2, phase = 1, dx = 3 },
    layers = {
      { x1 = 1, x2 = 54, y1 = 1, y2 = 4, dx = 4, dy = 2 },
      { x1 = 1, x2 = 54, y1 = 8, y2 = 11, dx = -4, dy = -2 },
      { x1 = 1, x2 = 18, y1 = 2, y2 = 10, dx = -3, dy = 1 },
      { x1 = 19, x2 = 38, y1 = 3, y2 = 9, dx = 4, dy = -2 },
      { x1 = 37, x2 = 54, y1 = 2, y2 = 10, dx = -3, dy = 2 },
      { x1 = 23, x2 = 33, y1 = 4, y2 = 8, dx = -3, dy = 2 },
    },
    ghosts = {
      { x1 = 1, x2 = 54, y1 = 1, y2 = 11, dx = 7, dy = -1, stride = 6, phase = 1 },
      { x1 = 1, x2 = 54, y1 = 1, y2 = 11, dx = -7, dy = 1, stride = 8, phase = 5 },
    },
  },
}

-- Source-space tears widen while the transformed layers move around them.
local tears = {
  { level = 1, x = 26, y = 6, length = 1 },
  { level = 1, x = 25, y = 7, length = 1 },
  { level = 2, x = 28, y = 5, length = 2 },
  { level = 2, x = 23, y = 8, length = 2 },
  { level = 3, x = 31, y = 4, length = 2 },
  { level = 3, x = 20, y = 9, length = 2 },
  { level = 3, x = 9, y = 6, length = 2 },
  { level = 4, x = 34, y = 3, length = 3 },
  { level = 4, x = 17, y = 10, length = 3 },
  { level = 4, x = 11, y = 7, length = 2 },
  { level = 5, x = 14, y = 8, length = 3 },
  { level = 5, x = 43, y = 5, length = 3 },
  { level = 6, x = 46, y = 4, length = 4 },
  { level = 6, x = 5, y = 9, length = 4 },
  { level = 2, x = 16, y = 1, length = 2 },
  { level = 3, x = 35, y = 11, length = 2 },
}

local function is_torn(level, x, y)
  for _, tear in ipairs(tears) do
    if tear.level <= level and y == tear.y then
      local growth = math.floor((level - tear.level) / 2)
      if x >= tear.x - growth and x < tear.x + tear.length + growth then
        return true
      end
    end
  end
  return false
end

local function transform(config, x, y)
  local center_x = (width + 1) / 2
  local center_y = (height + 1) / 2
  local dx = round((y - center_y) * config.skew_x)
  local dy = round((x - center_x) * config.skew_y)

  if config.scan and (y + config.scan.phase) % config.scan.period == 0 then
    dx = dx + config.scan.dx
  end

  for _, layer in ipairs(config.layers) do
    if inside(layer, x, y) then
      dx = dx + layer.dx
      dy = dy + layer.dy
    end
  end

  return x + dx, y + dy
end

local function make_frame(source, level, config)
  local output = blank_matrix()

  for y = 1, height do
    for x = 1, width do
      local char = source[y][x]
      if char ~= " " and not is_torn(level, x, y) then
        local tx, ty = transform(config, x, y)

        -- Sparse delayed copies resemble signal persistence without turning
        -- the whole wordmark into an unreadable duplicate.
        for _, ghost in ipairs(config.ghosts) do
          if inside(ghost, x, y) and (x + y + ghost.phase) % ghost.stride == 0 then
            draw(output, tx + ghost.dx, ty + ghost.dy, char, false)
          end
        end

        draw(output, tx, ty, char, true)
      end
    end
  end

  return {
    logo = render(to_lines(output)),
    color = config.color,
  }
end

local source = to_matrix(base)
local frames = {}
for level, config in ipairs(fracture_levels) do
  frames[#frames + 1] = make_frame(source, level, config)
end

M.Celeb = {
  original = render(base),
  frames = frames,
}

return M
