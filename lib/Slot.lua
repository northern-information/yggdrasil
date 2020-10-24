Slot = {}

function Slot:new(x, y, index)
  local s = setmetatable({}, { 
    __index = Slot,
    __tostring = function(s) return s:to_string() end
  })
  s.x = x ~= nil and x or 0
  s.y = y ~= nil and y or 0
  s.index = index ~= nil and index or 0
  s.empty = true
  s.focus = false
  s.midi_note = nil
  s.velocity = 127
  s.route = "synth"
  return s
end

function Slot:trigger()
  if self.midi_note == nil then return end
  if self.route == "synth" then
    synth:play(self:get_midi_note(), self:get_velocity())
  end
end

function Slot:to_string()
  return self.midi_note or self.index -- self.x .. ";" .. self.y
end

function Slot:set_midi_note(i)
  self.midi_note = i
  self:set_empty(false)
end

function Slot:set_velocity(i)
  print(i)
  self.velocity = util.clamp(i, 0, 127)
  self:set_empty(false)
end

function Slot:set_focus(bool)
  self.focus = bool
end

function Slot:is_focus()
  return self.focus
end

function Slot:clear()
  self:set_midi_note(nil)
  self:set_focus(false)
  self:set_empty(true)
end

function Slot:get_x()
  return self.x
end

function Slot:get_y()
  return self.y
end

function Slot:get_index()
  return self.index
end

function Slot:get_midi_note()
  return self.midi_note
end

function Slot:get_velocity()
  return self.velocity
end

function Slot:is_empty()
  return self.empty
end

function Slot:set_empty(bool)
  self.empty = bool
end