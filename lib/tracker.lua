tracker = {}

function tracker.init()
  tracker.focused = false
  tracker.focused_index = 0
  tracker.follow = false
  tracker.message = false
  tracker.message_value = ""
  tracker.playback = false
  tracker.slot_view = "midi"
  tracker.tracks = {}
  tracker.rows = 8
  tracker.cols = 1
  tracker.extents = 0
  for x = 1, tracker.cols do
    tracker.tracks[x] = Track:new(x)
    tracker.tracks[x]:fill(tracker.rows)
  end
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

function tracker:refresh()
  local e = 0
  for track_key, track in pairs(self:get_tracks()) do
    track:refresh()
    local te = track:get_extents()
    if e < te then e = te end
  end
  self:set_extents(e)
  graphics:set_tracker_view_dirty(true)
end

function tracker:render()
  graphics:update_tracker_view()
  graphics:draw_tracks()
  graphics:draw_hud()
  graphics:draw_terminal()
  graphics:draw_command_processing()
end



-- tracks



function tracker:load_track(track_number, data)
  -- compare incoming rows with existing rows
  -- if incoming is larger, we need to add more rows
  local track = self:get_track(track_number)
  if #data > track:get_depth() then
    self:set_rows(#data)
    track:fill(#data)
    self:refresh()
  end
  track:load(data)
  graphics:set_tracker_view_dirty(true)
end

function tracker:update_track(payload)
  local track = self:get_track(payload.x)
  if track ~= nil then
    tracker:focus_track(payload.x)
    if fn.table_contains_key(payload, "shift") then
      track:shift(payload.shift)
    end
    self:refresh()
  end
end

function tracker:set_track_depth(track, depth)
  if depth > self:get_rows() then
    self:set_rows(depth)
  end
  self:get_track(track):fill(depth)
end

function tracker:get_deepest_not_empty_position()
  local x, y = 1, 1
  for track_key, track in pairs(self:get_tracks()) do
    local p = track:get_position()
    if p > y  and not track:get_slot(p):is_empty() then
      y = track:get_position()
      x = track:get_x()
    end
  end
  return { x = x, y = y }
end



-- slots



function tracker:update_slot(payload)
  self:focus_slot(payload.x, payload.y)
  self:get_track(payload.x):update_slot(payload)
  self:refresh()
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



-- focus



function tracker:focus_track(x)
  self:unfocus()
  if not self:is_in_bounds(x) then
    self:set_message("Track " .. x .. " is out of bounds.")
  else
    self:get_track(x):focus()
    self:set_focused(true)
  end
  graphics:set_tracker_view_dirty(true)
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
        graphics:set_view_x(x)
        graphics:set_view_y(y)
        slot:set_focused(true)
      end
    end
  end
  graphics:set_tracker_view_dirty(true)
end

function tracker:get_focused_slots()
  local out = {}
  for track_key, track in pairs(self:get_tracks()) do
    for slot_key, slot in pairs(track:get_slots()) do
      if slot:is_focused() then
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

function tracker:get_focused_tracks()
  local out = {}
  for track_key, track in pairs(self:get_tracks()) do
    if track:is_focused() then
      table.insert(out, track)
    end
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

function tracker:unfocus()
  self:set_focused(false)
  self:set_focused_index(0)
  for k, tracks in pairs(self:get_focused_tracks()) do
    if track ~= nil then
      track:set_focused(false)
    end
  end
  for k, slot in pairs(self:get_focused_slots()) do
    if slot ~= nil then
      slot:set_focused(false)
    end
  end
  graphics:set_tracker_view_dirty(true)
end



-- primitive getters, setters, & checks



function tracker:get_tracks()
  return self.tracks
end

function tracker:get_track(x)
  return self.tracks[x]
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
  if bool then self:set_follow(false) end
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

function tracker:is_in_bounds(x, y)
  local x_ok = (x <= #self:get_tracks()) and (x > 0)
  local y_ok = true
  if y ~= nil then
    y_ok = (y <= self:get_rows()) and (y > 0)
  end
  return x_ok and y_ok
end

function tracker:index(x, y)
  return y + ((x - 1) * self.rows)
end

function tracker:set_message(s)
  self.message = true
  self.message_value = s
end

function tracker:get_message_value()
  return self.message_value
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

function tracker:set_slot_view(s)
  self.slot_view = s
  self:refresh()
end

function tracker:get_slot_view()
  return self.slot_view
end

function tracker:set_extents(i)
  self.extents = i
end

function tracker:get_extents()
  return self.extents
end

return tracker