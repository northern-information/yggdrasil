Track = {}

function Track:new(x)
  local t = setmetatable({}, { 
    __index = Track,
    __tostring = function(t) return t:to_string() end
  })
  t.x = x ~= nil and x or 0
  t.depth = 0
  t.position = 0
  t.direction = "descend"
  t.slots = {}
  t.extents = 0
  return t
end

function Track:refresh()
  local e = 0
  local tracker_slot_view = tracker:get_slot_view()
  for k, slot in pairs(self.slots) do
    slot:set_index(tracker:index(slot:get_x(), slot:get_y()))
    slot:set_view(tracker_slot_view)
    slot:refresh()
    local se = slot:get_extents()
    if e < se then e = se end
  end
  self:set_extents(e)
end



--- slot management



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

function Track:append_slot(slot)
  self.slots[#self.slots + 1] = slot
  self:refresh()
end

function Track:update_slot(payload)
  local slot = self:get_slot(payload.y)
  if slot ~= nil then
    if payload.y > self:get_depth() then
      self:fill(payload.y)
    end
    if fn.table_contains_key(payload, "phenomenon") then
      slot:set_phenomenon(payload.phenomenon)
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



--- tracking



function Track:advance()
  if self:get_direction() == "descend" then
    self:descend()
  elseif self:get_direction() == "ascend" then
    self:ascend()
  end
  self:trigger()
end

function Track:ascend()
  self:set_position(self:get_position() - 1)
end

function Track:descend()
  self:set_position(self:get_position() + 1)
end

function Track:trigger()
  for k, slot in pairs(self.slots) do
    if slot:get_y() == self:get_position() then
      slot:trigger()
    end
  end
end



-- focus



function Track:focus()
  local first_focus = false
  for k, slot in pairs(self:get_slots()) do
    slot:set_focus(true)
    tracker:set_focused_index(slot:get_index())
    if not first_focus then
      graphics:set_view_x(self:get_x())
      graphics:set_view_y(slot:get_y())
      first_focus = true
    end 
  end
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



function Track:get_slots()
  return self.slots
end

function Track:get_slot(i)
  return self.slots[i]
end

function Track:to_string()
  return self:get_x()
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

function Track:get_direction()
  return self.direction
end

function Track:set_direction(s)
  self.direction = s
end

function Track:set_extents(i)
  self.extents = i
end

function Track:get_extents()
  return self.extents
end

