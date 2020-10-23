 tracker = {}

function tracker.init()
  tracker.playback = false
  tracker.focused = false
  tracker.follow = false
  tracker.track = 1
  tracker.cols = 16
  tracker.rows = 8
  tracker.view = {
    x = 1,
    y = 1,
    rows = 0,
    cols = 0,
    rows_above = nil,
    rows_below = nil,
    current_row = 1,
    rows_per_view = 7,
    cols_per_view = 8,
  }
  tracker:update_view()
  tracker.slots = {}
  for x = 1, tracker.cols do
    for y = 1, tracker.rows do
      table.insert(tracker.slots, Slot:new(x, y))
    end
  end
  tracker.message = false
  tracker.message_value = ""
end

function tracker:render()
  graphics:draw_highlight(self.view)
  graphics:draw_cols(self.view)
  graphics:draw_slots(self.slots, self.view)
  graphics:draw_hud(self.view)
  graphics:draw_terminal(self.message, self.message_value)
  graphics:draw_command_processing()
end


function tracker:set_midi_note(payload)
  self:focus_slot(payload.x, payload.y)
  -- print(payload.x, payload.y)
  local slots = self:get_focused_slots()
  for k, slot in pairs(slots) do
    slot:set_midi_note(payload.midi_note)
  end
end

function tracker:set_rows(i)
  local _rows = self.rows
  self.rows = i
  if _rows < i then
    local start = i - (i - _rows) + 1
    for x = 1, self.cols do
      for y = start, self.rows do
        table.insert(self.slots, Slot:new(x, y))
      end
    end
  end
end

function tracker:load_column(col, data)
  if #data > self.rows then
    self:set_rows(#data)
  end
  for i = 1, #data do
    self:set_midi_note({
      x = col,
      y = i,
      midi_note = music:convert("ygg_to_midi", data[i])
    })
  end
end

function tracker.tracker_clock()
  while true do
    clock.sync(1)
    if tracker.playback == true then
      tracker:descend()
      fn.dirty_screen(true)
    end
  end
end

function tracker:ascend()
  self:set_track(self.track - 1)
  self:fire()
end

function tracker:descend()
  self:set_track(self.track + 1)
  self:fire()
end

function tracker:fire()
  self:set_current_row(self:get_track())
  self:trigger_slots()
  if self:is_follow() then
    self:pan_to_y(self:get_track())
  end
end

function tracker:trigger_slots()
  for k, slot in pairs(self.slots) do
    if slot:get_track() == self:get_track() then
      slot:trigger()
    end
  end
end

function tracker:handle_arrow(direction)
      if direction == "UP"    then self:pan_y(-1)
  elseif direction == "LEFT"  then self:pan_x(-1)
  elseif direction == "DOWN"  then self:pan_y(1)
  elseif direction == "RIGHT" then self:pan_x(1)
  end
end

function tracker:focus_slot(x, y)
  self:unfocus()
  if x > self.cols or y > self.rows then
    self:set_message(x .. "/" .. y .. " is out of bounds.")
  else
    for k, slot in pairs(self.slots) do
      if slot.x == x and slot.y == y then
        self:set_focused(true)
        slot:set_focus(true)
        self.view.x = x
        self.view.y = y
      end
    end
  end
  tracker:update_view()
end

function tracker:focus_col(x)
  self:unfocus()
  if x > self.cols then
    self:set_message("Column " .. x .. " is out of bounds.")
  else
    local first_focus = false
    for k, slot in pairs(self.slots) do
      if slot.x == x then
        self:set_focused(true)
        slot:set_focus(true)
        if not first_focus then
          self.view.x = x
          self.view.y = slot.y
          first_focus = true
        end
      end
    end
  end
  tracker:update_view()
end

function tracker:unfocus()
  self:set_focused(false)
  local slots = self:get_focused_slots()
  for k, slot in pairs(slots) do
    if slot ~= nil then
      slot:set_focus(false)
    end
  end
  tracker:update_view()
end

function tracker:get_focused_slots()
  local out = {}
  for k, slot in pairs(self.slots) do
    if slot:is_focus() then
      table.insert(out, slot)
    end
  end
  return out
end

function tracker:clear_focused_slots()
  local slots = self:get_focused_slots()
  for k, slot in pairs(slots) do
    if slot ~= nil then
      slot:clear()
    end
  end
end




function tracker:set_track(i)
  self.track = fn.cycle(i, 1, self.rows)
end

function tracker:get_track()
  return self.track
end

function tracker:toggle_playback()
  self:set_playback(not self.playback)
end

function tracker:set_playback(bool)
  self.playback = bool
end

function tracker:toggle_follow()
  self:set_follow(not self.follow)
end

function tracker:set_follow(bool)
  self.follow = bool
end

function tracker:is_follow()
  return self.follow
end

function tracker:set_current_row(i)
  self.view.current_row = util.clamp(i, 1, self.rows)
end

function tracker:set_focused(bool)
  self.focused = bool
end

function tracker:is_focused()
  return self.focused
end

function tracker:scroll_tracker(d)
  if d > 0 then
    tracker:descend()
  elseif d < 0 then
    tracker:ascend()
  end
end

function tracker:pan_x(d)
  self.view.x = util.clamp(self.view.x + d, 1, self.cols)
end

function tracker:pan_y(d)
  self.view.y = util.clamp(self.view.y + d, 1, self.rows)
  self:update_view()
end

function tracker:pan_to_y(y)
  self.view.y = util.clamp(y, 1, self.rows)
  self:update_view()
end

function tracker:update_view()
  self.view.rows = self.rows
  self.view.cols = self.cols
  self.view.rows_above = self.view.y > 1
  self.view.rows_below = self.view.y <= self.rows - 7
end

function tracker:set_message(s)
  self.message = true
  self.message_value = s
end

function tracker:clear_message()
  self.message = false
  self.message_value = ""
end

function tracker:has_message()
  return self.message
end

return tracker