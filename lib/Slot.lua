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
  s.focus = false
  s.midi_note = nil
  s.ygg_note = nil
  s.ipn_note = nil
  s.frequency = nil
  s.velocity = 127
  s.route = "synth"
  s.view = "midi"
  s.phenomenon = nil
  s.extents = nil
  s:refresh()
  return s
end

function Slot:trigger()
  if self:get_phenomenon() == "p" then return end
  if self:get_midi_note() ~= nil and self:get_route() == "synth" then
    synth:play(self:get_midi_note(), self:get_velocity())
  end
  graphics:register_slot_trigger(self:get_id())
end

function Slot:to_string()
  local v = self:get_view()
  local p = self:get_phenomenon()
  local out = ""
  if p ~= nil then
        if p == "x"      then out = "x" end
  else
        if v == "midi"   then out = self:get_midi_note() 
    elseif v == "index"  then out = self:get_index()
    elseif v == "ygg"    then out = self:get_ygg_note()
    elseif v == "ipn"    then out = self:get_ipn_note()
    elseif v == "freq"   then out = self:get_frequency()
    end
  end
  return out ~= nil and tostring(out) or "."
end

function Slot:refresh()
  local m = self:get_midi_note()
  if m ~= nil then
    self:set_ygg_note(music:convert("midi_to_ygg", m))
    self:set_ipn_note(music:convert("midi_to_ipn", m))
    self:set_frequency(music:convert("midi_to_freq", m))
  end
  self:set_extents(screen.text_extents(self:to_string()) + 4) -- 4 is the "left padding" pixel adjustment
end

function Slot:clear()
  self:clear_notes()
  self:set_phenomenon(nil)
  self:set_focus(false)
  self:set_empty(true)
end

function Slot:clear_notes()
  self:set_midi_note(nil)
  self:set_ygg_note(nil)
  self:set_ipn_note(nil)
  self:set_frequency(nil)
end


-- primitive getters, setters, & checks

function Slot:get_phenomenon()
  return self.phenomenon
end

function Slot:set_phenomenon(s)
  self.phenomenon = s
  self:clear_notes()
  self:set_empty(false)
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

function Slot:set_focus(bool)
  self.focus = bool
end

function Slot:is_focus()
  return self.focus
end

function Slot:get_id()
  return self.id
end

function Slot:get_x()
  return self.x
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

function Slot:get_route()
  return self.route
end

function Slot:set_route(s)
  self.route = s
end

function Slot:set_extents(i)
  self.extents = i
end

function Slot:get_extents()
  return self.extents
end