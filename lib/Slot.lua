Slot = {}

function Slot:new(x, y)
  local s = setmetatable({}, { 
    __index = Slot,
    __newindex = function(s, k, v) s:new_index(s, k, v) end,
    __tostring = function(s) return s:to_string() end
  })
  s.x = x ~= nil and x or 0
  s.y = y ~= nil and y or 0
  s.id = fn.id("slot")
  s.index = 0
  s.empty = true
  s.selected = false
  s.midi_note = nil
  s.ygg_note = nil
  s.ipn_note = nil
  s.frequency = nil
  s.velocity = 127
  s.m1 = 50
  s.m2 = 50
  s.clade = ""
  s.view = ""
  s.phenomenon = false
  s.payload = {}
  s.extents = nil
  s.sample_name = ""
  s:refresh()
  return s
end

function Slot:new_index(s, k, v)
  if s.save_keys == nil then
    rawset(s, "save_keys", {})
  end
  local block_list = {
    "x", "y", "index", "id", "selected", "extents"
  }
  if not fn.table_contains(block_list, k) then
    table.insert(s.save_keys, k)
  end
  rawset(s, k, v)
end

function Slot:get_save_keys()
  return self.save_keys
end

function Slot:get_editor_fields()
  return {
    {
      field_id = "ygg_note",
      display = "YGG",
      tab_index = 1,
      value_getter = function() return self:get_ygg_note() end,
      value_setter = function(x) self:set_ygg_note(x) end,
      value_clear = function() self:clear_notes() end,
      validator = function(x) return music:is_valid_ygg(x) end,
    },
    {
      field_id = "midi_note",
      display = "M|D|",
      tab_index = 2,
      value_getter = function() return self:get_midi_note() end,
      value_setter = function(x) self:set_midi_note(tonumber(x)) end,
      value_clear = function() self:clear_notes() end,
      validator = function(x) return (fn.is_int(tonumber(x))) and (music:is_valid_midi(tonumber(x))) end,
    },
    {
      field_id = "ypc",
      display = "YPC",
      tab_index = 3,
      action = "sample",
      action_method = function(s) selector:activate(ypc:get_samples(), s:get_sample_name() .. ".wav") end,
      value_getter = function() return self:get_sample_name() end,
      value_setter = function(x) self:set_sample_name(x) end,
      value_clear = function() self:set_sample_name("") end,
      validator = function(x) return true end,
    },
    -- {
    --   field_id = "phenomenon",
    --   display = "PHEN",
    --   tab_index = 4,
    --   value_getter = function() return "todo" end,
    --   value_setter = function(x) end,
    --   value_clear = function() end,
    --   validator = function(x) return true end,
    -- },
    {
      field_id = "velocity",
      display = "VEL",
      tab_index = 4,
      value_getter = function() return self:get_velocity() end,
      value_setter = function(x) self:set_velocity(tonumber(x)) end,
      value_clear = function() self:set_velocity(0) end,
      validator = function(x) return (fn.is_int(tonumber(x))) and (tonumber(x) >= 0) and (tonumber(x) <= 127) end,
    },
    {
      field_id = "m1",
      display = "M1",
      tab_index = 5,
      value_getter = function() return self:get_m1() end,
      value_setter = function(x) self:set_m1(tonumber(x)) end,
      value_clear = function() self:set_m1(50) end,
      validator = function(x) return (fn.is_int(tonumber(x))) and (tonumber(x) >= 0) and (tonumber(x) <= 99) end,
    },
    {
      field_id = "m2",
      display = "M2",
      tab_index = 6,
      value_getter = function() return self:get_m2() end,
      value_setter = function(x) self:set_m2(tonumber(x)) end,
      value_clear = function() self:set_m2(50) end,
      validator = function(x) return (fn.is_int(tonumber(x))) and (tonumber(x) >= 0) and (tonumber(x) <= 99) end,
    }
  }
end

function Slot:refresh()
  local m = self:get_midi_note()
  if m ~= nil then
    self:set_ygg_note(music:convert("midi_to_ygg", m)[1])
    self:set_ipn_note(music:convert("midi_to_ipn", m))
    self:set_frequency(music:convert("midi_to_freq", m))
  end
  self:set_extents(screen.text_extents(self:to_string()) + view:get_slot_left_padding())
end

function Slot:trigger()
  local track = tracker:get_track(self:get_x())
  graphics:register_slot_trigger(self:get_id())
  if not track:is_enabled() then return end
  
  -- notes
  if not track:is_muted()
    and (track:is_soloed() or not tracker:is_any_soloed()) then
    
    local clade = self:get_clade()
    local mixed_level = track:get_level() * self:get_velocity()
  
    if clade == "SYNTH" and self:get_midi_note() ~= nil then
      synth:play(
        track:get_voice(),
        self:get_midi_note(),
        mixed_level,
        self:get_m1() * .01, 
        self:get_m2() * .01
      )
    elseif clade == "MIDI" and self:get_midi_note() ~= nil then
      _midi:play(
        self:get_midi_note(),
        mixed_level,
        track:get_channel(),
        track:get_device(),
        track:get_id()
      )
    elseif clade == "YPC" then
      ypc:play(
        track:get_x(),
        self:get_sample_name(),
        self:get_frequency(),
        mixed_level / 127.0
      )
    elseif clade == "CROW" then 
      if track:is_jf() then
        _crow:jf(self:get_midi_note())
      else
        _crow:play(self:get_midi_note(), track:get_pair())
      end
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
    elseif p == "LACUNA" then
      track:disable()
      local new_track = tracker:get_track(self.payload.value)
      if new_track ~= nil then
        new_track:queue_event("enable", _clock:get_the_arrow_of_time() + 1)
      end
    elseif p == "LUCKY" then  
      local slots = track:get_not_empty_slots()
      if #slots ~= 1 then
        local new_y = 0
        repeat
          new_y = slots[math.random(1, #slots)]:get_y()
        until (new_y ~= self:get_y())
        track:set_position(new_y - 1)
      end
    elseif p == "OFF" then
      _midi:kill_notes_on_track(track:get_id())
    elseif p == "RANDOM" then  
      track:set_position(math.random(1, track:get_depth()))
    elseif p == "REVERSE" then  
      track:reverse_direction()
    elseif p == "RUIN" then  
      track:remove_slot(math.random(1, #track:get_slots()))
    elseif p == "SHIFT_PHENOMENON_DOWN" then  
      track:shift(self.payload.value)
    elseif p == "SHIFT_PHENOMENON_UP" then  
      track:shift(-self.payload.value)
    end
  end
  
end

function Slot:to_string()
  local out = nil
  local empty_character = "."
   local v = self:get_view()
      if v == "midi"   then out = self:get_midi_note() 
  elseif v == "index"  then out = self:get_index()
  elseif v == "ygg"    then out = self:get_ygg_note()
  elseif v == "ipn"    then out = self:get_ipn_note()
  elseif v == "freq"   then out = self:get_frequency()
  end
  out = ((out == nil) or (out == "")) and empty_character or out
  if view:is_velocity() then
    local v = "v" .. self:get_velocity()
    out = out ~= nil and out .. v or v
  end
  if view:is_m1() then
    local c = "m" .. self:get_m1()
    out = out ~= nil and out .. c or c
  end
  if view:is_m2() then
    local c = "m" .. self:get_m2()
    out = out ~= nil and out .. c or c
  end
  if self:get_clade() == "YPC" then
    if view:is_ypc() and self:get_sample_name() ~= "" then
      local y = "=" .. self:get_sample_name()
      out = out ~= nil and out .. y or empty_character .. y
    end
  end
  if self:is_phenomenon() then
    if view:is_phenomenon() then
      local p = "+" .. tostring(self.payload)
      out = out ~= nil and out .. p or p
    end
  end
  return out ~= nil and tostring(out) or empty_character
end

function Slot:clear()
  self:clear_notes()
  self:set_payload({})
  self:set_sample_name("")
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

function Slot:get_payload()
  return self.payload
end

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

function Slot:get_sample_name()
  return self.sample_name
end

function Slot:set_sample_name(s)
  if string.match(s, ".wav") then
    s = s:gsub(".wav", "")
  end
  self.sample_name = s
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

function Slot:set_m1(i)
  self.m1 = util.clamp(i, 0, 99)
end

function Slot:get_m1()
  return self.m1
end

function Slot:set_m2(i)
  self.m2 = util.clamp(i, 0, 99)
end

function Slot:get_m2()
  return self.m2
end