Slot = {}

function Slot:new(x, y)
  local s = setmetatable({}, { 
    __index = Slot,
    __tostring = function(s) return s:to_string() end
  })
  s.x = x ~= nil and x or 0
  s.y = y ~= nil and y or 0
  s.id = "slot-" .. fn.id()
  s.index = 0
  s.empty = true
  s.selected = false
  s.midi_note = nil
  s.ygg_note = nil
  s.ipn_note = nil
  s.frequency = nil
  s.velocity = 127
  s.clade = ""
  s.view = ""
  s.phenomenon = false
  s.payload = {}
  s.extents = nil
  s:refresh()
  return s
end

function Slot:refresh()
  local m = self:get_midi_note()
  if m ~= nil then
    self:set_ygg_note(music:convert("midi_to_ygg", m))
    self:set_ipn_note(music:convert("midi_to_ipn", m))
    self:set_frequency(music:convert("midi_to_freq", m))
  end
  self:set_extents(screen.text_extents(self:to_string()) + view:get_slot_left_padding())
end

function Slot:trigger()
  local track = tracker:get_track(self:get_x())
  
  -- notes
  if track:is_enabled()
    and not track:is_muted()
    and (track:is_soloed() or not tracker:is_any_soloed()) then
    
      local clade = self:get_clade()
      local mixed_level = track:get_level() * self:get_velocity()
    
      if clade == "SYNTH" and self:get_midi_note() ~= nil then
        synth:play(self:get_midi_note(), mixed_level)
      elseif clade == "MIDI" and self:get_midi_note() ~= nil then
        _midi:play(
          self:get_midi_note(),
          mixed_level,
          track:get_channel(),
          track:get_device(),
          track:get_id()
        )
      elseif clade == "SAMPLER" then
        print("trigger sampler")
        -- sampler:play(self:get_sample_name(), self:get_velocity(), self:get_pitch())
      elseif clade == "CROW" then 
        print("trigger crow")
      end

  end

  -- phenomenon
  if self:is_phenomenon() then
    local p = self.payload.class
    if p == "ANCHOR" then
      if self:get_y() ~= self.payload.value then
        track:set_position(self.payload.value)
      end
    elseif p == "END" then  
      track:set_position(0)
    elseif p == "LUCKY" then  
      local slots = track:get_not_empty_slots()
      local new_y = 0
      repeat
        new_y = slots[math.random(1, #slots)]:get_y()
      until new_y ~= self:get_y()
      track:set_position(new_y)
    elseif p == "OFF" then
      _midi:kill_notes_on_track(track:get_id())
    elseif p == "RANDOM" then  
      track:set_position(math.random(1, track:get_depth()))
    elseif p == "REVERSE" then  
      track:reverse_direction()
    end
  end
  
  graphics:register_slot_trigger(self:get_id())
end

function Slot:to_string()
  local out = nil
  local phenomenon = nil
   local v = self:get_view()
      if v == "midi"   then out = self:get_midi_note() 
  elseif v == "index"  then out = self:get_index()
  elseif v == "ygg"    then out = self:get_ygg_note()
  elseif v == "ipn"    then out = self:get_ipn_note()
  elseif v == "freq"   then out = self:get_frequency()
  elseif v == "vel"    then out = self:get_velocity()
  end
  if self:is_phenomenon() then
    if view:is_phenomenon() and self.payload.class ~= "OFF" then
      local p = "+" .. tostring(self.payload)
      out = out ~= nil and out .. p or p
    elseif self.payload.class == "OFF" then
      out = "off"
    end
  end

  return out ~= nil and tostring(out) or "."
end

function Slot:clear()
  self:clear_notes()
  self:set_payload({})
  self:set_phenomenon(false)
  self:set_selected(false)
  self:set_empty(true)
end

function Slot:clear_notes()
  self:set_midi_note(nil)
  self:set_ygg_note(nil)
  self:set_ipn_note(nil)
  self:set_frequency(nil)
end

function Slot:run_phenomenon(payload)
  if payload.class == "OFF" then
    self:clear_notes()
  end
  self:set_payload(payload)
  self:set_phenomenon(true)
  self:set_empty(false)
end



-- primitive getters, setters, & checks





function Slot:set_payload(payload)
  self.payload = payload
end

function Slot:is_phenomenon()
  return self.phenomenon
end

function Slot:set_phenomenon(bool)
  self.phenomenon = bool
end

function Slot:transpose_midi_note(semitones)
  if self:get_midi_note() ~= nil then
    self:set_midi_note(util.clamp(self:get_midi_note() + semitones, 0, 127))
  end
end

function Slot:get_midi_note()
  return self.midi_note
end

function Slot:set_midi_note(i)
  self.midi_note = i
  self:set_empty(false)
end

function Slot:get_ygg_note()
  return self.ygg_note
end

function Slot:set_ygg_note(s)
  self.ygg_note = s
  self:set_empty(false)
end

function Slot:get_ipn_note()
  return self.ipn_note
end

function Slot:set_ipn_note(s)
  self.ipn_note = s
  self:set_empty(false)
end

function Slot:get_frequency()
  return self.frequency
end

function Slot:set_frequency(f)
  self.frequency = f
  self:set_empty(false)
end

function Slot:set_selected(bool)
  self.select = bool
end

function Slot:is_selected()
  return self.select
end

function Slot:get_id()
  return self.id
end

function Slot:set_x(x)
  self.x = x
end

function Slot:get_x()
  return self.x
end

function Slot:set_y(i)
  self.y = i
end

function Slot:get_y()
  return self.y
end

function Slot:is_empty()
  return self.empty
end

function Slot:set_empty(bool)
  self.empty = bool
end

function Slot:get_index()
  return self.index
end

function Slot:set_index(i)
  self.index = i
end

function Slot:get_velocity()
  return self.velocity
end

function Slot:set_velocity(i)
  self.velocity = util.clamp(i, 0, 127)
  self:set_empty(false)
end

function Slot:get_view()
  return self.view
end

function Slot:set_view(s)
  self.view = s
end

function Slot:get_clade()
  return self.clade
end

function Slot:set_clade(s)
  self.clade = s
end

function Slot:set_extents(i)
  self.extents = i
end

function Slot:get_extents()
  return self.extents
end