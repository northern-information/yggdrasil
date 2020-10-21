Slot = {}

function Slot:new(x, y)
  local s = setmetatable({}, { 
    __index = Slot,
    __tostring = function(s) return s:to_string() end
  })
  s.x = x ~= nil and x or 0
  s.y = y ~= nil and y or 0
  s.focus = false
  return s
end

function Slot:to_string()
  return self.x .. ";" .. self.y
end

function Slot:set_focus(bool)
  self.focus = bool
end

function Slot:is_focus()
  return self.focus
end