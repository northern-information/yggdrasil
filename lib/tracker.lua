tracker = {}

function tracker.init()
  tracker.selected = false
  tracker.selected_index = 0
  tracker.follow = false
  tracker.message = false
  tracker.message_value = ""
  tracker.playback = false
  tracker.track_view = "ipn"
  tracker.extents = 0
  tracker.info = false
  tracker.generation = 0
  tracker.any_soloed = false
  --[[ cols will always == #tracks.
    rows * cols ~= always equal #slots, however.
    tracks can have different depths. ]]
  tracker.tracks = {}
  tracker.cols = config.settings.default_tracks
  tracker.rows = config.settings.default_depth
  for x = 1, tracker.cols do
    tracker:append_track_after(x - 1)
  end
end

function tracker.tracker_clock()
  while true do
    clock.sync(1)
    tracker:increment_generation()
    if tracker:is_playback() then
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



-- track management



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
  self:deselect()
  self:select_tracks(payload.x)
  if self:is_selected() then
    self:get_track(payload.x):update_every_other(payload)
  end
  self:refresh()
end

function tracker:update_track(payload)
  local track = self:get_track(payload.x)
  if track ~= nil then
    tracker:select_tracks(payload.x)
    if fn.table_contains_key(payload, "class") then
      if payload.class == "CLADE" then
        track:set_clade(payload.clade)
      elseif payload.class == "CROW" then
        if payload.pair ~= nil then
          track:set_pair(payload.pair)
        end
      elseif payload.class == "DEPTH" then
        if payload.depth ~= nil then
          self:set_track_depth(payload.x, payload.depth)
        end
      elseif payload.class == "MIDI" then
        if payload.device ~= nil then
          track:set_device(payload.device)
        elseif payload.channel ~= nil then
          track:set_channel(payload.channel)
        end
      elseif payload.class == "LEVEL" then
        track:set_level(payload.level)
      elseif payload.class == "YPC" then
        if payload.action ~= nil then
          if payload.action == "bank" then
            ypc:set_bank(payload.directory)
          elseif payload.action == "load" and payload.y ~= nil then
            track:update_slot(payload)
          elseif payload.action == "load" then
            local y = 1
            for k, slot in pairs(track:get_slots()) do
              payload["y"] = y
              track:update_slot(payload)
              y = y + 1
            end
          end
        end
      elseif payload.class == "SHADOW" then
        track:set_shadow(payload.shadow)
      elseif payload.class == "SHIFT" then
        track:shift(payload.shift)
      elseif payload.class == "CLOCK" then
        track:set_clock(payload.clock)
      elseif payload.class == "SYNTH" then
        if payload.voice ~= nil then
          track:set_voice(payload.voice)
        end
        if payload.y ~= nil then
          track:update_slot(payload)
        else
          local y = 1
          for k, slot in pairs(track:get_slots()) do
            payload["y"] = y
            track:update_slot(payload)
            y = y + 1
          end
        end
      else
        fn.print_matron_message("Error: No matches for payload:")
        tabutil.print(payload)
      end
    end
    self:refresh()
  end
end

function tracker:save_track(track_number, filename)
  local track = self:get_track(track_number)
  local slots = track:get_slots()
  local data = {}
  for k, slot in pairs(slots) do
    data[slot:get_y()] = slot:get_ygg_note()
  end
  filesystem:save(filesystem:get_tracks_path() .. filename, data)
  tracker:set_message("Saved " .. filename)
  view:set_tracker_dirty(true)
end

function tracker:load_track(track_number, filename)
  local full_path = filesystem:get_tracks_path() .. filename
  if not filesystem:file_or_directory_exists(full_path) then
    tracker:set_message(filename .. " not found.")
  else
    local file = assert(io.open(full_path, "r"))
    local data = {}
    for line in file:lines() do
      data[#data + 1] = line:gsub("%s+", "")
    end
   file:close()
    -- compare incoming rows with existing rows
    -- if incoming is larger, we need to add more rows
    local track = self:get_track(track_number)
    if #data > track:get_depth() then
      self:set_rows(#data)
      track:fill(#data)
      self:refresh()
    end
    track:load(data)
    self:set_message("Load successful.")
    view:set_tracker_dirty(true)
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

function tracker:clear_all_samples()
  for k, track in pairs(self:filter_tracks("CLADE", "YPC")) do
    for y = 1, track:get_depth() do
      track:update_slot({
        class = "YPC",
        filename = "",
        y = y
      })
    end
  end
end

function tracker:get_track_by_id(id)
  for k, track in pairs(self:get_tracks()) do
    if track:get_id() == id then
      return track
    end
  end
end

function tracker:sync(y)
  y = y == nil and 0 or y - 1 -- subtract one to get intuitive behavior
  for k, track in pairs(self:get_tracks()) do
    track:set_position(y)
  end
end

function tracker:ascend()
  for k, track in pairs(self:get_tracks()) do
    track:set_descend(false)
  end
end

function tracker:descend()
  for k, track in pairs(self:get_tracks()) do
    track:set_descend(true)
  end
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



function tracker:select_tracks(x1, x2)
  local valid_range = true
  if not self:is_in_bounds(x1) then
    valid_range = false
    self:set_message("Track " .. x1 .. " is out of bounds.")
  end
  if x2 ~= nil and not self:is_in_bounds(x2) then
    valid_range = false
    self:set_message("Track " .. x2 .. " is out of bounds.")
  end
  if valid_range then
    if self:is_selected() and x2 == nil then
      x2 = 0
      for k, track in pairs(self:get_selected_tracks()) do
        x2 = track:get_x() > x2 and track:get_x() or x2
      end
    end
    x2 = x2 ~= 0 and x2 or x1
    local t = {x1, x2}
    table.sort(t)
    for x = t[1], t[2] do
      self:get_track(x):select()
      self:set_selected(true)
    end
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
  for k, track in pairs(self:get_selected_tracks()) do
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
  -- 99 tracks is the limit
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
  if x == nil and not self:is_selected() then
    self:solo_all()
  elseif x == nil and self:is_selected() then
    for k, track in pairs(self:get_selected_tracks()) do
      track:solo()
    end
  elseif x ~= nil then
    tracker:get_track(x):solo()
  end
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
  if x == nil and not self:is_selected() then
    self:unsolo_all()
  elseif x == nil and self:is_selected() then
    for k, track in pairs(self:get_selected_tracks()) do
      track:unsolo()
    end
  elseif x ~= nil then
    tracker:get_track(x):unsolo()
  end
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
  if x == nil and not self:is_selected() then
    self:mute_all()
  elseif x == nil and self:is_selected() then
    for k, track in pairs(self:get_selected_tracks()) do
      track:mute()
    end
  elseif x ~= nil then
    tracker:get_track(x):mute()
  end
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
  if x == nil and not self:is_selected() then
    self:unmute_all()
  elseif x == nil and self:is_selected() then
    for k, track in pairs(self:get_selected_tracks()) do
      track:unmute()
    end
  elseif x ~= nil then
    tracker:get_track(x):unmute()
  end
  self:refresh()
end

function tracker:unmute_all()
  local tracks = self:get_tracks()
  for k, track in pairs(tracks) do
    track:unmute()
  end
  self:refresh()
end

function tracker:unshadow_all()
  local tracks = self:get_tracks()
  for k, track in pairs(tracks) do
    track:unshadow()
  end
  self:refresh()
end

function tracker:enable(x)
  if x == nil and not self:is_selected() then
    self:enable_all()
  elseif x == nil and self:is_selected() then
    for k, track in pairs(self:get_selected_tracks()) do
      track:enable()
    end
  elseif x ~= nil then
    tracker:get_track(x):enable()
  end
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
  if x == nil and not self:is_selected() then
    self:disable_all()
  elseif x == nil and self:is_selected() then
    for k, track in pairs(self:get_selected_tracks()) do
      track:disable()
    end
  elseif x ~= nil then
    tracker:get_track(x):disable()
  end
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


function tracker:increment_generation()
  self.generation = self.generation + 1
end

function tracker:get_generation()
  return self.generation
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

function tracker:append_track_after(x, shadow)
  if self:get_cols() + 1 <= config.settings.max_tracks then
    local track = Track:new(x + 1)
    table.insert(self.tracks, x + 1, track)
    if shadow then
      track:set_shadow(x)
    end
    self:set_cols(#self.tracks)
    view:set_tracks(#self.tracks)
    track:fill(self:get_rows())
    self:refresh()
  else
    self:set_message("Track limit of " .. config.settings.max_tracks .. " met.")
  end
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

function tracker:is_playback()
  return tracker.playback
end

function tracker:set_playback(bool)
  tracker.playback = bool
end

function tracker:stop()
  self:set_playback(false)
end

function tracker:start()
  self:set_playback(true)
end

return tracker