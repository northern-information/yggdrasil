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
  t.selected = false
  return t
end

function Track:refresh()
  local e = 0
  local tracker_slot_view = tracker:get_slot_view()
  self:update_slot_x()
  self:update_slot_y()
  for k, slot in pairs(self.slots) do
    slot:set_index(tracker:index(slot:get_x(), slot:get_y()))
    slot:set_view(tracker_slot_view)
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
    if not first_select then
      view:set_x(self:get_x())
      view:set_y(slot:get_y())
      first_select = true
    end 
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

function Track:set_selected(bool)
  self.selected = bool
end

function Track:is_selected()
  return self.selected
end
