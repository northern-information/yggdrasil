Slot = {}

function Slot:new(x, y)
  local s = setmetatable({}, { 
    __index = Slot,
    __tostring = function(s) return s:to_string() end
  })
  s.x = x ~= nil and x or 0
  s.y = y ~= nil and y or 0
  s.focus = false
  s.midi_note = ""
  return s
end

function Slot:to_string()
  return self.midi_note
end

function Slot:set_midi_note(i)
  self.midi_note = i
end

function Slot:set_focus(bool)
  self.focus = bool
end

function Slot:is_focus()
  return self.focus
end

function Slot:clear()
  self:set_midi_note("")
  self:set_focus(false)
end