tracker = {}

function tracker.init()
  tracker.playback = false
  tracker.focused = false
  tracker.focused_index = 0
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
    x_offset = 0,
    y_offset = 0,
  }
  tracker:update_view()
  tracker.slots = {}
  for y = 1, tracker.rows do
    for x = 1, tracker.cols do
      local index = tracker:index(x, y)
      tracker.slots[index] = Slot:new(x, y, index)
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

function tracker:update_slot(payload)
  self:focus_slot(payload.x, payload.y)
  local slot = self:get_focused_slots()
  if #slot == 1 then
    local s = slot[1]
    if fn.table_contains_key(payload, "midi_note") then
      s:set_midi_note(payload.midi_note)
    end
    if fn.table_contains_key(payload, "velocity") then
      s:set_velocity(payload.velocity)
    end
  end
end

function tracker:add_rows(i)
  -- make sure we're actually adding rows
  if i <= self.rows then return end
  -- cache the last row
  local cached_row = self.rows
  self:set_rows(self.rows + i)
  for y = cached_row + 1, self.rows - cached_row do
    -- even though we're adding rows we need to 
    -- fill in all the cols with slots
    for x = 1, self.cols do
      local index = tracker:index(x, y)
      tracker.slots[index] = Slot:new(x, y, index)
    end
  end
end

function tracker:load_column(col, data)
  -- compare incoming rows with existing rows
  -- if incoming is larger, we need to add more rows
  if #data > self.rows then
    self:add_rows(#data)
  end
  for i = 1, #data do
    self:update_slot({
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
    if slot:get_y() == self:get_track() then
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
        self:set_focused_index(slot:get_index())
        self.view.x = x
        self.view.y = y
        slot:set_focus(true)
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
        self:set_focused_index(slot:get_index())
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
  self:set_focused_index(0)
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

function tracker:set_focused_index(index)
  self.focused_index = index
end

function tracker:get_focused_index()
  return self.focused_index
end

function tracker:collect_slots_for_focus()
  local out = {}
  local slots = self:get_not_empty_slots()
  local i = 1
  for k, slot in fn.pairs_by_keys(slots) do
      out[i] = slot
      i = i + 1
  end 
  return out
end

function tracker:cycle_focus(d)
  self:set_follow(false)
  if self:is_focused() then
    local slots = self:collect_slots_for_focus()
    local sorted_index = 0
    for k, slot in pairs(slots) do
      if slot:get_index() == self:get_focused_index() then
        sorted_index = k
      end
    end
    local direction = d > 0 and 1 or -1
    next_focus = fn.cycle(sorted_index + direction, 1, #slots)
    self:focus_slot(slots[next_focus].x, slots[next_focus].y)
  end
end

function tracker:get_not_empty_slots()
  local slots = {}
  for k, slot in pairs(self.slots) do
    if not slot:is_empty() then
      table.insert(slots, slot)
    end
  end
  return slots
end

function tracker:pan_x(d)
  self.view.x = util.clamp(self.view.x + d, 1, self.cols)
  self:update_view()
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
  self.view.rows_below = self.view.y <= self.rows - 5
  self.view.x_offset = self.view.x - math.floor(self.view.cols_per_view / 2)
  self.view.y_offset = self.view.y - math.floor(self.view.rows_per_view / 2)
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

function tracker:index(x, y)
  return y + ((x - 1) * self.rows)
end

function tracker:set_rows(i)
  self.rows = i
end

return tracker