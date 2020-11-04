tracker = {}

function tracker.init()
  tracker.selected = false
  tracker.selected_index = 0
  tracker.follow = false
  tracker.message = false
  tracker.message_value = ""
  tracker.playback = false
  tracker.track_view = "midi"
  tracker.tracks = {}
  tracker.rows = config.settings.default_rows
  tracker.cols = config.settings.default_cols
  tracker.extents = 0
  tracker.info = false
  -- mixer
  tracker.any_soloed = false
  for x = 1, tracker.cols do
    tracker:append_track_after(x - 1)
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
  self:set_any_soloed(false)
  for k, track in pairs(self:get_tracks()) do
    track:set_x(k)
    track:set_view(self:get_track_view())
    if track:is_soloed() then
      print(tostring(track) .. " is soloed.")
      self:set_any_soloed(true)
    end
  end
  for track_key, track in pairs(self:get_tracks()) do
    track:refresh()
    local te = track:get_extents()
    if e < te then e = te end
  end
  self:set_extents(e)
  view:set_tracker_dirty(true)
end



-- tracks management



function tracker:filter_tracks(state, clade_name)
  local out = {}
  local tracks = tracker:get_tracks()
  for k, track in pairs(tracks) do
    if (state == "MUTED"    and track:is_muted())
    or (state == "SOLOED"   and track:is_soloed())
    or (state == "ENABLED"  and track:is_enabled())
    or (state == "DISABLED" and not track:is_enabled())
    or (state == "SHADOWED" and track:is_shadowed())
    or (state == "CLADE"    and track:get_clade() == clade_name)
    then
      table.insert(out, track)
    end
  end
  return out
end


function tracker:update_every_other(payload)
  self:select_track(payload.x)
  if self:is_selected() then
    self:get_track(payload.x):update_every_other(payload)
  end
end

function tracker:update_track(payload)
  local track = self:get_track(payload.x)
  if track ~= nil then
    tracker:select_track(payload.x)
    if fn.table_contains_key(payload, "class") then
      if payload.class == "CLADE" then
        track:set_clade(payload.clade)
      elseif payload.class == "DEPTH" then
        self:set_track_depth(payload.x, payload.depth)
      elseif payload.class == "LEVEL" then
        track:set_level(payload.level)
      elseif payload.class == "SHADOW" then
        track:set_shadow(payload.shadow)
      elseif payload.class == "SHIFT" then
        track:shift(payload.shift)
      else
        track:update(payload)
      end
    end
    self:refresh()
  end
end

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
  view:set_tracker_dirty(true)
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

function tracker:remove(x, y)
  if y ~= nil then
    tracker:remove_slot(x, y)
  else
    tracker:remove_track(x)
  end
end

function tracker:remove_slot(track, y)
  self:get_track(track):remove_slot(y)
  self:refresh()
end

function tracker:remove_track(track)
  table.remove(self.tracks, track)
  self:set_cols(#self.tracks)
  view:set_tracks(#self.tracks)
  self:refresh()
end

function tracker:clear_tracks()
  for i = 1, self:get_cols() do
    self:clear_track(i)
  end
end

function tracker:clear_track(i)
  self:get_track(i):clear()
end


-- slot management



function tracker:update_slot(payload)
  local track = self:get_track(payload.x)
  if track ~= nil then
    track:update_slot(payload)
  end
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



-- select



function tracker:select_track(x)
  self:deselect()
  if not self:is_in_bounds(x) then
    self:set_message("Track " .. x .. " is out of bounds.")
  else
    self:get_track(x):select()
    self:set_selected(true)
  end
  view:set_tracker_dirty(true)
end

function tracker:select_slot(x, y)
  self:deselect()
  if not self:is_in_bounds(x, y) then
    self:set_message(x .. "/" .. y .. " is out of bounds.")
  else
    for k, slot in pairs(self:get_track(x):get_slots()) do
      if slot:get_y() == y then
        self:set_selected(true)
        self:set_selected_index(slot:get_index())
        view:set_x(x)
        view:set_y(y)
        slot:set_selected(true)
      end
    end
  end
  view:set_tracker_dirty(true)
end

function tracker:get_selected_slots()
  local out = {}
  for track_key, track in pairs(self:get_tracks()) do
    for slot_key, slot in pairs(track:get_slots()) do
      if slot:is_selected() then
        table.insert(out, slot)
      end
    end
  end
  return out
end

function tracker:clear_selected_slots()
  local slots = self:get_selected_slots()
  for k, slot in pairs(slots) do
    if slot ~= nil then
      slot:clear()
    end
  end
end

function tracker:get_selected_tracks()
  local out = {}
  for track_key, track in pairs(self:get_tracks()) do
    if track:is_selected() then
      table.insert(out, track)
    end
  end
  return out
end

function tracker:cycle_select(d)
  self:set_follow(false)
  if self:is_selected() then
    local slots = self:collect_slots_for_select()
    local sorted_index = 0
    for k, slot in pairs(slots) do
      if slot:get_index() == self:get_selected_index() then
        sorted_index = k
      end
    end
    local direction = d > 0 and 1 or -1
    next_select = fn.cycle(sorted_index + direction, 1, #slots)
    self:select_slot(slots[next_select].x, slots[next_select].y)
  end
end

function tracker:collect_slots_for_select()
  local out = {}
  local slots = self:get_not_empty_slots()
  local i = 1
  for k, slot in fn.pairs_by_keys(slots) do
      out[i] = slot
      i = i + 1
  end 
  return out
end

function tracker:deselect()
  self:set_selected(false)
  self:set_selected_index(0)
  for k, tracks in pairs(self:get_selected_tracks()) do
    if track ~= nil then
      track:set_selected(false)
    end
  end
  for k, slot in pairs(self:get_selected_slots()) do
    if slot ~= nil then
      slot:set_selected(false)
    end
  end
  view:set_tracker_dirty(true)
end



-- music!



function tracker:chord(payload)
  local end_track = payload.x + #payload.midi_notes
  -- check & create tracks
  -- "-1" to adjust for the first track!
  while self:get_cols() < end_track - 1 do
    self:append_track_after(#self:get_tracks())
  end
  -- fill the chord horizontally
  local note_index = 1
  for i = payload.x, end_track - 1 do
    self:get_track(i):update_slot{
      midi_note = payload.midi_notes[note_index],
      y = payload.y
    }
    note_index = note_index + 1
  end
end



-- mixer



function tracker:solo(x)
  tracker:get_track(x):solo()
  self:refresh()
end

function tracker:solo_all()
  local tracks = self:get_tracks()
  for k, track in pairs(tracks) do
    track:solo()
  end
  self:refresh()
end

function tracker:unsolo(x)
  tracker:get_track(x):unsolo()
  self:refresh()
end

function tracker:unsolo_all()
  local tracks = self:get_tracks()
  for k, track in pairs(tracks) do
    track:unsolo()
  end
  self:refresh()
end

function tracker:mute(x)
  tracker:get_track(x):mute()
  self:refresh()
end

function tracker:mute_all()
  local tracks = self:get_tracks()
  for k, track in pairs(tracks) do
    track:mute()
  end
  self:refresh()
end

function tracker:unmute(x)
  tracker:get_track(x):unmute()
  self:refresh()
end

function tracker:unmute_all()
  local tracks = self:get_tracks()
  for k, track in pairs(tracks) do
    track:unmute()
  end
  self:refresh()
end

function tracker:enable(x)
  tracker:get_track(x):enable()
  self:refresh()
end

function tracker:enable_all()
  local tracks = self:get_tracks()
  for k, track in pairs(tracks) do
    track:enable()
  end
  self:refresh()
end

function tracker:disable(x)
  tracker:get_track(x):disable()
  self:refresh()
end

function tracker:disable_all()
  local tracks = self:get_tracks()
  for k, track in pairs(tracks) do
    track:disable()
  end
  self:refresh()
end



-- primitive getters, setters, & checks




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

function tracker:set_selected(bool)
  self.selected = bool
  if bool then self:set_follow(false) end
end

function tracker:is_selected()
  return self.selected
end

function tracker:set_selected_index(index)
  self.selected_index = index
end

function tracker:get_selected_index()
  return self.selected_index
end

function tracker:append_track_after(x)
  local track = Track:new(x + 1)
  table.insert(self.tracks, x + 1, track)
  self:set_cols(#self.tracks)
  view:set_tracks(#self.tracks)
  track:fill(self:get_rows())
  self:refresh()
end

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

function tracker:set_track_view(s)
  self.track_view = s
  self:refresh()
end

function tracker:get_track_view()
  return self.track_view
end

function tracker:set_extents(i)
  self.extents = i
end

function tracker:get_extents()
  return self.extents
end

function tracker:toggle_info()
  self:set_info(not self.info)
end

function tracker:set_info(bool)
  self.info = bool
end

function tracker:is_info()
  return self.info
end

function tracker:set_any_soloed(bool)
  self.any_soloed = bool
end

function tracker:is_any_soloed()
  return self.any_soloed
end

return tracker