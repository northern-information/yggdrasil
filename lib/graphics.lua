graphics = {}

function graphics.init()
  -- frames and animation state
  graphics.fps = 30
  graphics.frame = 0
  graphics.quarter_frame = 0
  graphics.cursor_frame = 0
  graphics.run_command_frame = 0
  graphics.glow = 0
  graphics.glow_up = true
  graphics.hud = true
  graphics.command_icon = {}
  -- splash screen
  graphics.ni_splash_lines_open = {}
  graphics.ni_splash_lines_close = {}
  graphics.ni_splash_lines_close_available = {}
  for i = 1, 45 do graphics.ni_splash_lines_open[i] = i end
  for i = 1, 64 do graphics.ni_splash_lines_close_available[i] = i end
  graphics.ni_splash_done = false
  graphics.yggdrasil_splash_scale = 6
  graphics.yggdrasil_splash_segments = graphics:get_yggdrasil_segments(0, 35, graphics.yggdrasil_splash_scale)
  graphics.yggdrasil_splash_done = false
  graphics.yggdrasil_gui_scale = 2
  graphics.yggdrasil_gui_segments = graphics:get_yggdrasil_segments(0, 50, graphics.yggdrasil_gui_scale)
  -- tracker view
  graphics.slot_width_min = 16
  graphics.slot_width = graphics.slot_width_min
  graphics.slot_height = 7
  graphics.tracker_view_dirty = true
  graphics.view_x = 1
  graphics.view_x_offset = 0
  graphics.view_y = 1
  graphics.view_y_offset = 0
  graphics.rows_above = nil
  graphics.rows_below = nil
  graphics.rows_per_view = 7
  graphics.cols_per_view = 8
  graphics.slot_extents = graphics.slot_width_min
  -- slots
  graphics.slot_triggers = {}
end

function graphics.redraw_clock()
  while true do
    if graphics:is_tracker_dirty() then
      graphics:update_tracker_view()
      graphics:set_tracker_view_dirty(false)
      fn.dirty_screen(true)
    end
    if fn.dirty_screen() then
      redraw()
      fn.dirty_screen(false)
    end
    graphics:decrement_slot_triggers()
    clock.sleep(1 / graphics.fps)
  end
end



-- tracker



function graphics:update_tracker_view()
  local y = self:get_view_y()
  local x = self:get_view_x()
  if tracker:is_follow() then
    local deepest = tracker:get_deepest_not_empty_position()
    x = deepest.x
    y = deepest.y
  end
  self:set_slot_extents(tracker:get_extents())
  self:set_rows_above(y > 2)
  self:set_rows_below(y <= tracker:get_rows() - 5) -- todo what is this magic number
  self:set_cols_per_view(math.floor(128 / self:get_slot_width()))
  self:set_view_x_offset(x - math.ceil(self:get_cols_per_view() / 2))
  self:set_view_y_offset(y - math.ceil(self:get_rows_per_view() / 2))
end

function graphics:draw_hud(view)
  if not self.hud then return end
  self:draw_cols()
  local swm, sw, sh =  self:get_slot_width_min(), self:get_slot_width(), self:get_slot_height()
  self:rect(0, 0, swm, 64, 0)
  self:rect(0, 0, 128, sh, 0)
  -- vertical indicator to scroll up
  if self:get_rows_above()then
    for i = 1, 16 do
      self:mls(swm, sh - 1 + i, swm, sh + i, 16 - i)
    end
  end
  -- horizontal rule under the top numbers
  if self:get_rows_above() then
    self:mls(swm - 1, sh, 128, sh, 15)
  end
  -- vertical indicator to scroll down
  if self:get_rows_below() then
    local adjust_y = tracker:has_message() and -9 or 0
    for i = 1, 16 do 
      self:mls(swm, 56 - i + adjust_y, swm, 55 - i + adjust_y, 16 - i)
    end
  end
  -- col numbers, start at 2 because of the column HUD
  local start = 2
  if self:get_slot_extents() > swm then
    start = 1
  end
  for i = start, self:get_cols_per_view() do
    local value = i + self:get_view_x_offset()
    self:text_right(
      (i * sw - 2),
      (sh - 2),
      ((value < 1 or value > tracker:get_cols()) and "" or value),
      15
    )
  end
  -- row numbers, start at 2 because of the row HUD
  for i = 2, self:get_rows_per_view() + 2 do
    local value = i + self:get_view_y_offset()
    self:text_right(
      (swm - 3),
      (i * sh),
      ((value < 1 or value > tracker:get_rows()) and "" or value),
      15
    )
  end
end

function graphics:draw_tracks()
  for k, track in pairs(tracker:get_tracks()) do
    self:draw_slots(track)
  end
end

function graphics:draw_slots(track)
  local slots = track:get_slots()
  local slot_triggers = self:get_slot_triggers()
  local sw, sh = self:get_slot_width(), self:get_slot_height()
  local w = self:get_view_x_offset() * sw
  local h = self:get_view_y_offset() * sh
  for k, slot in pairs(slots) do
    if slot:get_y() <= track:get_depth() then
      local triggered = slot_triggers[slot:get_id()]
      if slot:is_focused() or triggered ~= nil then
        local background = 15
        local foreground = 0
        if triggered ~= nil then
          local l = slot_triggers[slot:get_id()].level
          foreground = math.abs(15 - l)
          background = l
        end
        self:rect(
          ((slot:get_x() - 1) * sw) - w,
          ((slot:get_y() - 1) * sh + 1) - h,
          sw, sh, background
        )
        self:text_right(
          (slot:get_x() * sw - 2) - w,
          (slot:get_y() * sh) - h,
          tostring(slot), foreground
        )
      else
        self:text_right(
          (slot:get_x() * sw - 2) - w,
          (slot:get_y() * sh) - h,
          tostring(slot), 15
        )
      end
    end
  end
end



function graphics:draw_cols()
  for i = 1, self:get_cols_per_view() do
    local x = (i - 1) * self:get_slot_width()
    local value = i + self:get_view_x_offset()
    if value > 1 and value <= tracker:get_cols() + 1 then
      for ii = 1, (self:get_rows_per_view() * 2) do
        if self:get_rows_above() and (
            (self:get_view_y_offset() > 0  and not self:is_hud()) or
            (self:get_view_y_offset() > -1 and     self:is_hud())
          ) then
          local adjust_y = self:is_hud() and self:get_slot_height() or -1
          self:mls(x, ii - 1 + adjust_y, x, ii + adjust_y, 16 - ii)
        end
        if self:get_rows_below() then
          local adjust_y = tracker:has_message() and -9 or 0
          self:mls(x, 56 - ii + adjust_y, x, 55 - ii + adjust_y, 16 - ii)
        end
      end
    end
  end
end

function graphics:draw_terminal()
  local message = tracker:has_message()
  local message_value = tracker:get_message_value()
  local height = 9
  if message then
    height = 18
  end
  self:mls(0, 64 - height, 128, 64 - height - 1, 15)
  self:rect(0, 64 - height, 128, height, 0)
  if message then
    self:text(5, 54, message_value, 1)
  end
  self:text(0, 62, buffer:get(), 15)
  local adjust = 1
  if buffer:get_extents() > 0 then
    adjust = 3
  end
  self:mlrs(buffer:get_extents() + adjust, 56, 0, 7, self.cursor_frame)
end

function graphics:draw_command_processing()
  if self.run_command_frame < self.frame then return end  
  local x = 123
  local y = 55
  local l = self.frame < self.run_command_frame - 15 and 15 or (self.run_command_frame - self.frame)
  self:rect(x, y, 5, 9, 0)
  local this = math.random(1, 5)
  self.command_icon[this] = util.clamp(self.command_icon[this] - math.random(1, 2), -7, 0)
  for i = 1, #self.command_icon do
    self:mlrs(x - 1 + i, y + 9, 0, self.command_icon[i], l)
  end
  for i = 1, #self.command_icon do
    local l = math.abs(self.command_icon[i])
    self:mlrs(x - 1 + i, y + 9, 0, -math.floor(l / 2), 0)
  end
end

function graphics:run_command()
  self.command_icon = {0, 0, 0, 0, 0}
  self.run_command_frame = self.frame + 30
end

function graphics:handle_arrow(direction)
  tracker:set_follow(false)
      if direction == "UP"    or direction == "k" then self:pan_y(-1)
  elseif direction == "LEFT"  or direction == "h" then self:pan_x(-1)
  elseif direction == "DOWN"  or direction == "j" then self:pan_y(1)
  elseif direction == "RIGHT" or direction == "l" then self:pan_x(1)
  end
end

function graphics:pan_x(d)
  tracker:set_follow(false)
  self:set_view_x(util.clamp(self:get_view_x() + d, 1, tracker:get_cols()))
  self:set_tracker_view_dirty(true)
end

function graphics:pan_y(d)
  tracker:set_follow(false)
  self:set_view_y(util.clamp(self:get_view_y() + d, 1, tracker:get_rows()))
  self:set_tracker_view_dirty(true)
end

function graphics:pan_to_y(y)
  tracker:set_follow(false)
  self:set_view_y(util.clamp(y, 1, tracker:get_rows()))
  self:set_tracker_view_dirty(true)
end


-- housekeeping



function graphics:toggle_hud()
  self.hud = not self.hud
end

function graphics:is_hud()
  return self.hud
end

function graphics:frame_clock()
  while true do
    graphics:handle_frames()
    fn.dirty_screen(true)
    clock.sleep(1 / graphics.fps)
  end
end

function graphics:handle_frames()
  self.frame = self.frame + 1
  self.quarter_frame = self.frame % 16 == 0 and self.quarter_frame + 1 or self.quarter_frame
  if self.frame % 16 == 0 then
    self.glow_up =  not self.glow_up
  end
  self.glow = self.glow_up and self.frame % 16 or math.abs((self.frame % 16) - 16)
  self.cursor_frame = fn.cycle(self.cursor_frame - 1, 0, 16)
end

function graphics:ping_cursor_frame()
  self.cursor_frame = 16
end

function graphics:setup()
  screen.clear()
  screen.aa(0)
  self:reset_font()
end

function graphics:reset_font()
  screen.font_face(0)
  screen.font_size(8)
end

function graphics:teardown()
  screen.update()
end



-- tracker view



function graphics:set_slot_width(i)
  self.slot_width = i
end

function graphics:get_slot_width()
  return self.slot_width
end

function graphics:set_slot_height(i)
  self.slot_height = i
end

function graphics:get_slot_height()
  return self.slot_height
end

function graphics:set_tracker_view_dirty(bool)
  self.tracker_view_dirty = bool
end

function graphics:is_tracker_dirty(bool)
  return self.tracker_view_dirty
end

function graphics:get_view_x()
  return self.view_x
end

function graphics:set_view_x(i)
  self.view_x = i
end

function graphics:get_view_y()
  return self.view_y
end

function graphics:set_view_y(i)
  self.view_y = i
end

function graphics:get_rows_above()
  return self.rows_above
end

function graphics:set_rows_above(i)
  self.rows_above = i
end

function graphics:get_rows_below()
  return self.rows_below
end

function graphics:set_rows_below(i)
  self.rows_below = i
end

function graphics:get_rows_per_view()
  return self.rows_per_view
end

function graphics:set_rows_per_view(i)
  self.rows_per_view = i
end

function graphics:get_cols_per_view()
  return self.cols_per_view
end

function graphics:set_cols_per_view(i)
  self.cols_per_view = i
end

function graphics:get_view_x_offset()
  return self.view_x_offset
end

function graphics:set_view_x_offset(i)
  self.view_x_offset = i
end

function graphics:get_view_y_offset()
  return self.view_y_offset
end

function graphics:set_view_y_offset(i)
  self.view_y_offset = i
end

function graphics:get_slot_extents()
  return self.slot_extents
end

function graphics:set_slot_extents(i)
  self.slot_extents = i
  if i > self:get_slot_width_min() then
    self.slot_width = i
  else
    self.slot_width = self:get_slot_width_min()
  end
end

function graphics:get_slot_width_min()
  return self.slot_width_min 
end

function graphics:set_slot_width_min(i)
  self.slot_width_min  = i
end

function graphics:get_slot_triggers()
  return self.slot_triggers
end

function graphics:register_slot_trigger(id)
  self.slot_triggers[id] = { id = id, level = 15 }
end

function graphics:decrement_slot_triggers()
  for id, st in pairs(self:get_slot_triggers()) do
    self.slot_triggers[id].level = st.level - 3
    if self.slot_triggers[id].level < 0 then
      self.slot_triggers[id] = nil
    end
  end
end



-- northern information graphics abstractions



function graphics:mlrs(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line_rel(x2, y2)
  screen.stroke()
end

function graphics:mls(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line(x2, y2)
  screen.stroke()
end

function graphics:rect(x, y, w, h, l)
  screen.level(l or 15)
  screen.rect(x, y, w, h)
  screen.fill()
end

function graphics:circle(x, y, r, l)
  screen.level(l or 15)
  screen.circle(x, y, r)
  screen.fill()
end

function graphics:text(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text(s)
end

function graphics:text_right(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_right(s)
end

function graphics:text_center(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_center(s)
end



-- northern information & yggdrasil splash screen



function graphics:splash()
  if fn.break_splash() then
    self.ni_splash_done = true
    self.yggdrasil_splash_done = true
  end
  local col_x = 34
  local row_x = 34
  local y = 45
  local l = self.frame >= 49 and 0 or 15
  if self.frame >= 49 and self.frame < 168 then
    self:rect(0, 0, 128, 50, 15)
  end
  self:ni(col_x, row_x, y, l)
  if #self.ni_splash_lines_open > 1 then 
    local delete = math.random(1, #self.ni_splash_lines_open)
    table.remove(self.ni_splash_lines_open, delete)
    for i = 1, #self.ni_splash_lines_open do
      self:mlrs(1, self.ni_splash_lines_open[i] + 4, 128, 1, 0)
    end
  end
  if self.frame >= 49 then
    self:text_center(64, 60, "NORTHERN INFORMATION")
  end
  if self.frame > 100 then
    if #self.ni_splash_lines_close_available > 0 then 
      local add = math.random(1, #self.ni_splash_lines_close_available)
      table.insert(self.ni_splash_lines_close, self.ni_splash_lines_close_available[add])
      table.remove(self.ni_splash_lines_close_available, add)
    end
    for i = 1, #self.ni_splash_lines_close do
      self:mlrs(1, self.ni_splash_lines_close[i], 128, 1, 0)
    end
  end
  if #self.ni_splash_lines_close_available == 0 then
    self.ni_splash_done = true
  end
  if self.frame >= 168 then
    if self.frame <= 300 then
      self:yggdrasil_random_on()
    end
    if (self.frame >= 168 and self.frame <= 250) or (self.frame >= 340) then
      for i = 1, #self.yggdrasil_splash_segments do
        self.yggdrasil_splash_segments[i].l = util.clamp(self.yggdrasil_splash_segments[i].l - 1, 0, 15)
      end
    elseif self.frame > 250 then
      for i = 1, #self.yggdrasil_splash_segments do
        self.yggdrasil_splash_segments[i].l = util.clamp(self.yggdrasil_splash_segments[i].l + 1, 0, 15)
      end
    end
  end
  if self.frame >= 168 then
    for k, segment in pairs(self.yggdrasil_splash_segments) do
      screen.level(segment.l)
      screen.move(segment.x - self.yggdrasil_splash_scale, segment.y)
      screen.line_rel(-self.yggdrasil_splash_scale, self.yggdrasil_splash_scale)
      screen.stroke()
    end
  end
  if self.frame >= 370 then
    self.yggdrasil_splash_done = true
  end
  if self.ni_splash_done and self.yggdrasil_splash_done then
    fn.break_splash(true)
    page:select(1)
  end
  fn.dirty_screen(true)
end

function graphics:yggdrasil_random_on()
  local on = math.random(1, #self.yggdrasil_splash_segments)
  if self.yggdrasil_splash_segments[on].l == 0 then
    self.yggdrasil_splash_segments[on].l = 15
  end
end

function graphics:get_yggdrasil_segments(x, y, scale)
  local s           = scale
  local x           = x
  local baseline    = y
  local asc_line    = baseline - s
  local asc_2_line  = baseline - (s * 2)
  local asc_3_line  = baseline - (s * 3)
  local asc_4_line  = baseline - (s * 4)
  local desc_line   = baseline + s
  local desc_2_line = baseline + (s * 2)
  return {
    -- y
    { l = 0, x = x + (s * 5), y = asc_2_line },
    { l = 0, x = x + (s * 4), y = asc_line },
    { l = 0, x = x + (s * 6), y = asc_2_line },
    { l = 0, x = x + (s * 5), y = asc_line },
    { l = 0, x = x + (s * 4), y = baseline },
    { l = 0, x = x + (s * 3), y = desc_line },
    { l = 0, x = x + (s * 2), y = desc_2_line },
    -- g
    { l = 0, x = x + (s * 7), y = asc_2_line },
    { l = 0, x = x + (s * 6), y = asc_line },
    { l = 0, x = x + (s * 8), y = asc_2_line },
    { l = 0, x = x + (s * 7), y = asc_line },
    { l = 0, x = x + (s * 6), y = baseline} ,
    { l = 0, x = x + (s * 5), y = desc_line },
    { l = 0, x = x + (s * 4), y = desc_2_line },
    -- g
    { l = 0, x = x + (s * 9),  y = asc_2_line },
    { l = 0, x = x + (s * 8),  y = asc_line },
    { l = 0, x = x + (s * 10), y = asc_2_line },
    { l = 0, x = x + (s * 9),  y = asc_line },
    { l = 0, x = x + (s * 8),  y = baseline },
    { l = 0, x = x + (s * 7),  y = desc_line },
    { l = 0, x = x + (s * 6),  y = desc_2_line },
    -- d
    { l = 0, x = x + (s * 11), y = asc_2_line },
    { l = 0, x = x + (s * 10), y = asc_line },
    { l = 0, x = x + (s * 14), y = asc_4_line },
    { l = 0, x = x + (s * 13), y = asc_3_line },
    { l = 0, x = x + (s * 12), y = asc_2_line },
    { l = 0, x = x + (s * 11), y = asc_line },
    -- r
    { l = 0, x = x + (s * 13), y = asc_2_line },
    { l = 0, x = x + (s * 12), y = asc_line },
    { l = 0, x = x + (s * 14), y = asc_2_line },
    -- a
    { l = 0, x = x + (s * 15), y = asc_2_line },
    { l = 0, x = x + (s * 14), y = asc_line },
    { l = 0, x = x + (s * 16), y = asc_2_line },
    { l = 0, x = x + (s * 15), y = asc_line },
    -- s
    { l = 0, x = x + (s * 17), y = asc_2_line },
    { l = 0, x = x + (s * 17), y = asc_line },
    -- i
    { l = 0, x = x + (s * 21), y = asc_4_line },
    { l = 0, x = x + (s * 19), y = asc_2_line },
    { l = 0, x = x + (s * 18), y = asc_line },
    -- l
    { l = 0, x = x + (s * 22), y = asc_4_line },
    { l = 0, x = x + (s * 21), y = asc_3_line },
    { l = 0, x = x + (s * 20), y = asc_2_line },
    { l = 0, x = x + (s * 19), y = asc_line }
  }
end

function graphics:draw_yggdrasil_gui_logo()
  for k, segment in pairs(self.yggdrasil_gui_segments) do
    screen.level(5)
    screen.move(segment.x - self.yggdrasil_gui_scale, segment.y)
    screen.line_rel(-self.yggdrasil_gui_scale, self.yggdrasil_gui_scale)
    screen.stroke()
  end
end

function graphics:ni(col_x, row_x, y, l)
  self:n_col(col_x, y, l)
  self:n_col(col_x+20, y, l)
  self:n_col(col_x+40, y, l)
  self:n_row_top(row_x, y, l)
  self:n_row_top(row_x+20, y, l)
  self:n_row_top(row_x+40, y, l)
  self:n_row_bottom(row_x+9, y+37, l)
  self:n_row_bottom(row_x+29, y+37, l)
end

function graphics:n_col(x, y, l)
  self:mls(x, y, x+12, y-40, l)
  self:mls(x+1, y, x+13, y-40, l)
  self:mls(x+2, y, x+14, y-40, l)
  self:mls(x+3, y, x+15, y-40, l)
  self:mls(x+4, y, x+16, y-40, l)
  self:mls(x+5, y, x+17, y-40, l)
end

function graphics:n_row_top(x, y, l)
  self:mls(x+20, y-39, x+28, y-39, l)
  self:mls(x+20, y-38, x+28, y-38, l)
  self:mls(x+19, y-37, x+27, y-37, l)
  self:mls(x+19, y-36, x+27, y-36, l)
end

function graphics:n_row_bottom(x, y, l)
  self:mls(x+21, y-40, x+29, y-40, l)
  self:mls(x+21, y-39, x+29, y-39, l)
  self:mls(x+20, y-38, x+28, y-38, l)
  self:mls(x+20, y-37, x+28, y-37, l)
end

return graphics