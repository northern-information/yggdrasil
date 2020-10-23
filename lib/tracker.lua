tracker = {}

function tracker.init()
  tracker.playback = false
  tracker.focused = false
  tracker.track = 1
  tracker.cols = 8
  tracker.rows = 8
  tracker.view = {
    x = 1,
    y = 1,
    rows_above = false,
    rows_below = true,
    current_row = 1,
    rows_per_view = 7,
    cols_per_view = 8
  }
  tracker.slots = {}
  for x = 1, tracker.cols do
    for y = 1, tracker.rows do
      table.insert(tracker.slots, Slot:new(x, y))
    end
  end
  tracker.message = false
  tracker.message_value = ""
end

function tracker:set_midi_note(payload)
  self:focus(payload.x, payload.y)
  print(payload.x, payload.y)
  local slot = self:get_focused_slot()
  slot:set_midi_note(payload.midi_note)
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
      tracker:advance()
      fn.dirty_screen(true)
    end
  end
end

function tracker:advance()
  self:set_track(self.track + 1)
  self:set_current_row(self:get_track())
  self:trigger_slots()
end

function tracker:trigger_slots()
  for k, slot in pairs(self.slots) do
    if slot:get_track() == self:get_track() then
      slot:trigger()
    end
  end
end

function tracker:set_track(i)
  self.track = fn.cycle(self.track + 1, 1, self.rows)
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

function tracker:set_current_row(i)
  self.view.current_row = util.clamp(i, 1, self.rows)
end


function tracker:scroll_x(d)
  self.view.x = util.clamp(self.view.x + d, 1, self.cols)
end

function tracker:scroll_y(d)
  self.view.y = util.clamp(self.view.y + d, 1, self.rows)
  self.view.rows_above = self.view.y > 1
  self.view.rows_below = self.view.y <= self.rows - 7
end

function tracker:handle_arrow(direction)
      if direction == "UP"    then self:scroll_y(-1)
  elseif direction == "LEFT"  then self:scroll_x(-1)
  elseif direction == "DOWN"  then self:scroll_y(1)
  elseif direction == "RIGHT" then self:scroll_x(1)
  end
end

function tracker:focus(x, y)
  self:unfocus()
  if x > self.cols or y > self.rows then
    self:set_message(x .. "/" .. y .. " is out of bounds.")
  else
    for k, slot in pairs(self.slots) do
      if slot.x == x and slot.y == y then
        self:set_focused(true)
        slot:set_focus(true)
        -- if (self.view.x > x) or (self.view.cols_per_view < self.view.x) then
        --   self.view.x = x
        -- end
        -- if (self.view.y < y) or (self.view.rows_per_view > y) then
        --   self.view.y = y
        -- end
      end
    end
  end
end

function tracker:set_focused(bool)
  self.focused = bool
end

function tracker:is_focused()
  return self.focused
end

function tracker:unfocus()
  self:set_focused(false)
  local focused_slot = self:get_focused_slot()
  if focused_slot ~= nil then
    focused_slot:set_focus(false)
  end
end

function tracker:get_focused_slot()
  for k, slot in pairs(self.slots) do
    if slot:is_focus() then
      return slot
    end
  end
end

function tracker:clear_focused_slot()
  local slot = self:get_focused_slot()
  if slot ~= nil then
    slot:clear()
  end
end

function tracker:render()
  graphics:draw_highlight(self.view)
  graphics:draw_cols(self.view)
  graphics:draw_slots(self.slots, self.view)
  graphics:draw_terminal(self.message, self.message_value)
  graphics:draw_command_processing()
end

function tracker:set_message(s)
  self.message = true
  self.message_value = s
end

function tracker:clear_message()
  self.message = false
  self.message_value = ""
end

return tracker