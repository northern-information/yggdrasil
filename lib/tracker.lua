tracker = {}

function tracker.init()
  tracker.playback = false
  tracker.focused = false
  tracker.focused_index = 0
  tracker.follow = false
  tracker.cols = 16
  tracker.rows = 8
  tracker.tracks = {}
  for x = 1, tracker.cols do
    tracker.tracks[x] = Track:new(x)
    tracker.tracks[x]:fill(tracker.rows)
  end
  tracker:update_indices()
  tracker.view = {
    x = 1,
    y = 1,
    rows = 0,
    cols = 0,
    rows_above = nil,
    rows_below = nil,
    cols_left = nil,
    cols_right = nil,
    current_row = 1,
    rows_per_view = 7,
    cols_per_view = 8,
    x_offset = 0,
    y_offset = 0,
  }
  tracker:update_view()
  tracker.message = false
  tracker.message_value = ""
end

function tracker:render()
  graphics:draw_highlight(self.view)
  graphics:draw_cols(self.view)
  graphics:draw_slots(self:get_all_slots(), self.view)
  graphics:draw_hud(self.view)
  graphics:draw_terminal(self.message, self.message_value)
  graphics:draw_command_processing()
end

function tracker:get_all_slots()
  local slots = {}
  for track_key, track in pairs(self:get_tracks()) do
    for slot_key, slot in pairs(track:get_slots()) do
      table.insert(slots, slot)
    end
  end
  return slots
end



function tracker:load_track(track, data)
  -- compare incoming rows with existing rows
  -- if incoming is larger, we need to add more rows
  if #data > self.rows then
    self:set_rows(#data)
    self:update_view()
    for k, track in pairs(self:get_tracks()) do
      track:fill(#data)
    end
    self:update_indices()
  end
  self:get_tracks()[track]:load(data)
end

function tracker.tracker_clock()
  while true do
    clock.sync(1)
    if tracker.playback == true then
      for k, track in pairs(tracker:get_tracks()) do
        track:advance()
      end
      fn.dirty_screen(true)
    end
  end
end


function tracker:focus_slot(x, y)
  self:unfocus()
  if not self:is_in_bounds(x, y) then
    self:set_message(x .. "/" .. y .. " is out of bounds.")
  else
    for k, slot in pairs(self:get_track(x):get_slots()) do
      if slot:get_y() == y then
        self:set_focused(true)
        self:set_focused_index(slot:get_index())
        self:set_view("x", x)
        self:set_view("y", y)
        slot:set_focus(true)
      end
    end
  end
  tracker:update_view()
end

function tracker:focus_track(x)
  self:unfocus()
  if not self:is_in_bounds(x) then
    self:set_message("Track " .. x .. " is out of bounds.")
  else
    self:get_tracks()[x]:focus()
    tracker:set_focused(true)
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
  for track_key, track in pairs(self:get_tracks()) do
    for slot_key, slot in pairs(track:get_slots()) do
      if slot:is_focus() then
        table.insert(out, slot)
      end
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
  for track_keys, track in pairs(self:get_tracks()) do
    for slot_keys, slot in pairs(track:get_slots()) do
      if not slot:is_empty() then
        table.insert(slots, slot)
      end
    end
  end
  return slots
end

function tracker:handle_arrow(direction)
      if direction == "UP"    then self:pan_y(-1)
  elseif direction == "LEFT"  then self:pan_x(-1)
  elseif direction == "DOWN"  then self:pan_y(1)
  elseif direction == "RIGHT" then self:pan_x(1)
  end
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

function tracker:is_in_bounds(x, y)
  local check = x <= #self:get_tracks() and x > 0
  if y ~= nil then
    check = y <= self:get_rows() and y > 0
  end
  return check
end

function tracker:update_view()
  self:set_view("rows", self:get_rows())
  self:set_view("cols", self:get_cols())
  self:set_view("rows_above", self:get_view("y") > 2)
  self:set_view("rows_below", self:get_view("y") <= self:get_rows() - 5) -- todo what is this magic number
  self:set_view("cols_left", self:get_view("x") > 3)
  self:set_view("cols_right", self:get_view("x") <= self:get_cols() - 5) -- todo what is this magic number
  self:set_view("x_offset", self:get_view("x") - math.floor(self:get_view("cols_per_view") / 2))
  self:set_view("y_offset", self:get_view("y") - math.floor(self:get_view("rows_per_view") / 2))
end

function tracker:update_indices()
  for track_key, track in pairs(self:get_tracks()) do
    for slot_key, slot in pairs(track:get_slots()) do
      slot:set_index(self:index(slot.x, slot.y))
    end
  end
end

function tracker:update_slot(payload)
  self:focus_slot(payload.x, payload.y)
  self:get_tracks()[payload.y]:update_slot(payload)
end


function tracker:index(x, y)
  return y + ((x - 1) * self.rows)
end

function tracker:set_view(key, value)
  self.view[key] = value
end

function tracker:get_view(key)
  return self.view[key]
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

function tracker:set_cols(i)
  self.cols = i
end

function tracker:get_cols()
  return self.cols
end

function tracker:set_rows(i)
  self.rows = i
end

function tracker:get_rows()
  return self.rows
end

function tracker:get_tracks()
  return self.tracks
end

function tracker:get_track(x)
  return self.tracks[x]
end

return tracker