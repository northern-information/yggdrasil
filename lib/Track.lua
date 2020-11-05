Track = {}

function Track:new(x)
  local t = setmetatable({}, { 
    __index = Track,
    __tostring = function(t) return t:to_string() end
  })
  t.x = x ~= nil and x or 0
  t.id = "track-" .. fn.id()
  t.depth = 0
  t.position = 0
  t.descend = true
  t.view = ""
  t.slots = {}
  t.extents = 0
  t.selected = false
  t.clock_sync = 1
  -- mixer
  t.enabled = true
  t.muted = false
  t.soloed = false
  t.level = 1.0
  t.shadow = 0
  t.clade = config.settings.default_clade
  -- synth
  t.voice = 1
  t.c1 = 99
  t.c2 = 99
  -- midi
  t.channel = 1
  t.device = 1
  -- sampler
  t.tbd = 1
  -- crow
  t.pair = 1
  return t
end

function Track:refresh()
  local e = 0
  local tracker_slot_view = tracker:get_track_view()
  self:update_slot_x()
  self:update_slot_y()
  for k, slot in pairs(self.slots) do
    slot:set_index(tracker:index(slot:get_x(), slot:get_y()))
    slot:set_view(tracker_slot_view)
    slot:set_clade(self:get_clade())
    slot:set_view(self:get_view())
    slot:refresh()
    local se = slot:get_extents()
    if e < se then e = se end
  end
  self:set_extents(e)
end

function Track:select()
  self:set_selected(true)
  local first_select = false
  for k, slot in pairs(self:get_slots()) do
    slot:set_selected(true)
    tracker:set_selected_index(slot:get_index())
    if not page:is("MIXER") and not page:is("CLADES") then
      if not first_select then
        view:set_x(self:get_x())
        view:set_y(slot:get_y())
        first_select = true
      end 
    end
  end
end

function Track:clear()
  self:clear_slots()
  self:unmute()
  self:unsolo()
  self:enable()
  self:set_level(1.0)
end

--- tracking



function Track:advance()
  if self:is_descending() then
    self:set_position(self:get_position() + 1)
  elseif not self:is_descending() then
    self:set_position(self:get_position() - 1)
  end
  self:trigger()
end

function Track:trigger()
  self:get_slot(self:get_position()):trigger()
end



-- transformations



function Track:shift(i)
  if i == 0 then
    tracker:set_message("Cannot shift 0.")
  else
    if i < 0 then
      self:set_slots(fn.reverse_shift_table(self:get_slots(), math.abs(i)))
    elseif i > 0 then
      self:set_slots(fn.shift_table(self:get_slots(), i))
    end
    self:update_slot_y()
    self:refresh()
  end
end

function Track:fill(depth)
  local cached_depth = self:get_depth()
  if depth > self:get_depth() then
    self:set_depth(depth)
    for y = cached_depth + 1, depth do
      self:append_slot(Slot:new(self.x, y))
    end
  elseif depth < self:get_depth() then
    self:set_depth(depth)
    for k, slot in pairs(self:get_slots()) do
      if slot:get_y() > depth then
        slot:clear()
      end
    end
  end
  self:refresh()
end



--- slot management



function Track:update_every_other(payload)
  local start_y = payload.y
  local gap = payload.value
  local notes = payload.midi_notes
  if start_y > self:get_depth() then
    tracker:set_message("Error: " .. start_y .. " is deeper than track " .. self:get_x() .. ".")
  else
    local slots = self:get_slots()
    local next_y_update = start_y
    local next_note_index = 1
    for i = 1, self:get_depth() do
      if i == next_y_update then
        self:update_slot{
          y = next_y_update,
          midi_note = notes[next_note_index]
        }
        next_y_update = next_y_update + 1 + gap -- the "1" simply accounts for this slot
        next_note_index = fn.cycle(next_note_index + 1, 1, #notes)
      end
    end
  end
end

function Track:update_slot(payload)
  local slot = self:get_slot(payload.y)
  if slot ~= nil then
    if payload.y > self:get_depth() then
      self:fill(payload.y)
    end
    if payload.phenomenon then
      slot:run_phenomenon(payload)
      self:set_view("phenomenon")
    end
    if payload.class == "TRANSPOSE_SLOT" then  
      slot:transpose_midi_note(payload.value)
    end
    if fn.table_contains_key(payload, "midi_note") then
      slot:set_midi_note(payload.midi_note)
    end
    if fn.table_contains_key(payload, "velocity") then
      slot:set_velocity(payload.velocity)
    end
    slot:refresh()
    self:refresh()
  end
end

function Track:append_slot(slot)
  self.slots[#self.slots + 1] = slot
  self:refresh()
end

function Track:remove_slot(y)
  table.remove(self.slots, y)
  self:set_depth(#self.slots)
  self:refresh()
end

function Track:clear_slots()
  for i = 1, self:get_depth() do
    self:clear_slot(i)
  end
end

function Track:clear_slot(y)
  self:get_slot(y):clear()
end



-- load, copy, paste, update slots



function Track:load(data)
  if #data > self:get_depth() then
    self:fill(#data)
  end
  local x = self:get_x()
  for i = 1, #data do
    self:update_slot({
      x = x,
      y = i,
      midi_note = music:convert("ygg_to_midi", data[i])
    })
  end
end



-- getters & setters


function Track:update_slot_y()
  for k, slot in pairs(self:get_slots()) do
    slot:set_y(k)
  end
end

function Track:update_slot_x()
  for k, slot in pairs(self:get_slots()) do
    slot:set_x(self:get_x())
  end
end

function Track:get_not_empty_slots()
  local slots = {}
    for slot_keys, slot in pairs(self:get_slots()) do
      if not slot:is_empty() then
        table.insert(slots, slot)
      end
    end
  return slots
end

function Track:get_selected_slots()
  local slots = {}
    for slot_keys, slot in pairs(self:get_slots()) do
      if slot:is_selected() then
        table.insert(slots, slot)
      end
    end
  return slots
end

function Track:get_id()
  return self.id
end

function Track:set_slots(t)
  self.slots = t
end

function Track:get_slots()
  return self.slots
end

function Track:get_slot(i)
  return self.slots[i]
end

function Track:to_string()
  return self:get_x()
end

function Track:set_x(x)
  self.x = x
end

function Track:get_x()
  return self.x
end

function Track:set_depth(i)
  self.depth = i
end

function Track:get_depth()
  return self.depth
end

function Track:set_position(i)
  self.position = fn.cycle(i, 1, self:get_depth())
end

function Track:get_position()
  return self.position
end

function Track:reverse_direction()
  self:set_descend(not self:is_descending())
end

function Track:is_descending()
  return self.descend
end

function Track:set_descend(bool)
  self.descend = bool
end

function Track:set_extents(i)
  self.extents = i
end

function Track:get_extents()
  return self.extents
end

function Track:set_selected(bool)
  self.selected = bool
end

function Track:is_selected()
  return self.selected
end

function Track:is_muted()
  return self.muted
end

function Track:set_muted(bool)
  self.muted = bool
end

function Track:toggle_muted()
  self.muted = (not self.muted)
end

function Track:mute()
  self:set_muted(true)
end

function Track:unmute()
  self:set_muted(false)
end

function Track:is_soloed()
  return self.soloed
end

function Track:set_soloed(bool)
  self.soloed = bool
end

function Track:toggle_solo()
  self.soloed = (not self.soloed)
end

function Track:solo()
  self:set_soloed(true)
end

function Track:unsolo()
  self:set_soloed(false)
end

function Track:is_enabled()
  return self.enabled
end

function Track:set_enabled(bool)
  self.enabled = bool
end

function Track:toggle_enabled()
  self:set_enabled(not self:get_enabed())
end

function Track:disable()
  self:set_enabled(false)
end

function Track:enable()
  self:set_enabled(true)
end

function Track:is_shadow()
  return (self:get_shadow() ~= false)
end

function Track:set_shadow(i)
  if fn.is_int(i) and i > 0 then
    local target_track = tracker:get_track(i)
    self.shadow = target_track:get_id()
    self:set_clade(target_track:get_clade())
  else
    self.shadow = false
  end
end

function Track:get_shadow()
  return self.shadow
end

function Track:unshadow()
  self:set_shadow(false)
end

function Track:get_level()
  return self.level
end

function Track:set_level(f)
  self.level = f
end

function Track:get_clade()
  return self.clade
end

function Track:set_clade(s)
  self.clade = s
end
function Track:synth()
  self:set_clade("SYNTH")
end

function Track:is_synth()
  return self:get_clade() == "SYNTH"
end

function Track:midi()
  self:set_clade("MIDI")
end

function Track:is_midi()
  return self:get_clade() == "MIDI"
end

function Track:sampler()
  self:set_clade("SAMPLER")
end

function Track:is_sampler()
  return self:get_clade() == "SAMPLER"
end

function Track:crow()
  self:set_clade("CROW")
end

function Track:is_crow()
  return self:get_clade() == "CROW"
end

function Track:get_view()
  return self.view
end

function Track:set_view(s)
  self.view = s
end

function Track:get_device()
  return self.device
end

function Track:set_device(i)
  self.device = util.clamp(i, 1, 4)
end

function Track:get_channel()
  return self.channel
end

function Track:set_channel(i)
  self.channel = util.clamp(i, 1, 16)
end

function Track:get_voice()
  return self.voice
end

function Track:set_voice(i)
  self.voice = util.clamp(i, 1, 3)
end

function Track:get_c1()
  return self.c1
end

function Track:set_c1(i)
  self.c1 = util.clamp(i, 0, 99)
end

function Track:get_c2()
  return self.c2
end

function Track:set_c2(i)
  self.c2 = util.clamp(i, 0, 99)
end

function Track:get_pair()
  return self.pair
end

function Track:set_pair(i)
  self.pair = util.clamp(i, 1, 2)
end

function Track:get_clock_sync()
  return self.clock_sync
end

function Track:set_clock_sync(f)
  self.clock_sync = f
end