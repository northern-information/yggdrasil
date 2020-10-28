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
  s.focused = false
  s.midi_note = nil
  s.ygg_note = nil
  s.ipn_note = nil
  s.frequency = nil
  s.velocity = 127
  s.route = "synth"
  s.view = "midi"
  s.phenomenon = false
  s.phenomenon_class = ""
  s.phenomenon_prefix = ""
  s.phenomenon_value = nil
  s.phenomenon_payload = {}
  s.extents = nil
  s:refresh()
  return s
end

function Slot:trigger()
  -- if self:is_phenomenon() then
  --   if self:get_phenomenon_class() == "ANCHOR" then
  --     local position = self:get_phenomenon_value()
  --     local y = self:get_y()


print("trigger")
-- does phenomenon need to be a class?


  --     if position ~= y then
  --       local track = tracker:get_track(y)
  --       track:set_position(position)
  --     end
  --   else
  --     tracker:get_track(self:get_x()):phenomenon(self:get_phenomenon_value())
  --   end
  -- elseif self:get_midi_note() ~= nil and self:get_route() == "synth" then
  --   synth:play(self:get_midi_note(), self:get_velocity())
  -- end
  graphics:register_slot_trigger(self:get_id())
end

function Slot:to_string()
  local out = ""
  if self:is_phenomenon() then
    local value = self:get_phenomenon_value()
    local prefix = self:get_phenomenon_prefix()
    if prefix ~= nil then
      out = prefix
    end
    if value ~= nil then
      out = out .. value
    end
  else
     local v = self:get_view()
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
  self:clear_phenomenon()
  self:set_focused(false)
  self:set_empty(true)
end

function Slot:clear_phenomenon()
  self:set_phenomenon_value(nil)
  self:set_phenomenon_class("")
  self:set_phenomenon_prefix("")
  self:set_phenomenon_payload({})
  self:set_phenomenon(false)
end

function Slot:clear_notes()
  self:set_midi_note(nil)
  self:set_ygg_note(nil)
  self:set_ipn_note(nil)
  self:set_frequency(nil)
end



-- primitive getters, setters, & checks



function Slot:exotic_phenomenon(payload)
  self:clear_notes()
  self:set_phenomenon_payload(payload)
  self:set_phenomenon_class(payload.class)
  self:set_phenomenon_prefix(payload.prefix)
  self:set_phenomenon_value(payload.value)
  self:set_phenomenon(true)
  self:set_empty(false)
end

function Slot:is_phenomenon()
  return self.phenomenon
end

function Slot:set_phenomenon(bool)
  self.phenomenon = bool
end

function Slot:get_phenomenon_payload()
  return self.phenomenon_payload
end

function Slot:set_phenomenon_payload(payload)
  self.phenomenon_payload = payload
end

function Slot:get_phenomenon_class()
  return self.phenomenon_class
end

function Slot:set_phenomenon_class(s)
  self.phenomenon_class = s
end

function Slot:get_phenomenon_prefix()
  return self.phenomenon_prefix
end

function Slot:set_phenomenon_prefix(s)
  self.phenomenon_prefix = s
end

function Slot:get_phenomenon_value()
  return self.phenomenon_value
end

function Slot:set_phenomenon_value(s)
  self.phenomenon_value = s
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

function Slot:set_focused(bool)
  self.focus = bool
end

function Slot:is_focused()
  return self.focus
end

function Slot:get_id()
  return self.id
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