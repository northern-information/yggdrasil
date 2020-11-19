editor = {}

function editor.init()
  editor.open = false
  editor.track = nil
  editor.slot = nil
  editor.fields = {}
  editor.tab_index = 0
end

function editor:activate(x, y)
  self:set_open(true)
  local track = tracker:get_track(x)
  self:set_track(track)
  local slot = track:get_slot(y)
  if slot ~= nil then
    self:set_slot(slot)
    local fields = slot:get_editor_fields()
    for k, field in pairs(fields) do
      self:add_field(field)
    end
    self:select_field(1)
  end
end

function editor:select_field(i)
  for k, field in pairs(self.fields) do
    field.input_field:set_focus(false)
  end
  self.fields[i].input_field:set_focus(true)
  self:set_tab_index(i)
end

function editor:cycle_fields(i)
  self:select_field(fn.cycle(self:get_tab_index() + i, 1, #self:get_fields()))
end

function editor:increment_fields(i)
  self:select_field(util.clamp(self:get_tab_index() + i, 1, #self:get_fields()))
end

function editor:add_field(field)
  field["input_field"] = Field:new()
  field.input_field:load_string(field:value_getter())
  self.fields[#self.fields + 1] = field
end

function editor:clear()
  self:set_open(false)
  self:set_track(nil)
  self:set_slot(nil)
  self:set_tab_index(0)
  self:set_fields({})
end

function editor:commit_and_close()
  -- commit...
  self:clear()
end



-- getters & setters



function editor:get_title()
  if self:get_slot() == nil or self:get_track() == nil then return "EMPTINESS..." end
  local ipn = self:get_slot():get_ipn_note()
  return "X" .. self:get_track():get_x() .. "Y" .. self:get_slot():get_y() .. (ipn ~= nil and ipn or "")
end


function editor:is_valid()
  for k, field in pairs(self:get_fields()) do
    if not field.validator(tostring(field.input_field)) then
      return false
    end
  end
  return true
end

function editor:is_unsaved_changes()
  for k, field in pairs(self:get_fields()) do
    if tostring(field.value_getter()) ~= tostring(field.input_field) then
      return true
    end
  end
  return false
end

function editor:get_focused_field()
  return self.fields[self.tab_index]
end

function editor:set_track(track)
  self.track = track
end

function editor:get_track()
  return self.track
end

function editor:set_slot(slot)
  self.slot = slot
end

function editor:get_slot()
  return self.slot
end

function editor:close()
  self:set_open(false)
end

function editor:is_open()
  return self.open
end

function editor:set_open(bool)
  self.open = bool
end

function editor:set_tab_index(i)
  self.tab_index = i
end

function editor:get_tab_index()
  return self.tab_index
end

function editor:set_fields(t)
  self.fields = t
end

function editor:get_fields()
  return self.fields
end

return editor