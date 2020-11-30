editor = {}

function editor.init()
  editor.open = false
  editor.track = nil
  editor.slot = nil
  editor.fields = {}
  editor.field_index = {}
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
  self.fields[self:get_field_index()[i]].input_field:set_focus(true)
  self:set_tab_index(i)
end

function editor:cycle_fields(i)
  self:select_field(fn.cycle(self:get_tab_index() + i, 1, #self:get_field_index()))
end

function editor:increment_fields(i)
  self:select_field(util.clamp(self:get_tab_index() + i, 1, #self:get_field_index()))
end

function editor:add_field(field)
  field["input_field"] = Field:new(39)
  local value = field:value_getter() ~= nil and field:value_getter() or ""
  field.input_field:load_string(value)
  self.field_index[#self:get_field_index() + 1] = field.field_id
  self.fields[field.field_id] = field
end

function editor:clear()
  self:set_track(nil)
  self:set_slot(nil)
  self:set_tab_index(0)
  self:set_fields({})
  self:set_field_index({})
end

function editor:add(s)
  local field = self:get_focused_field()
  field.input_field:add(s)
  self:sync_ygg_and_midi(field)
end

function editor:backspace()
  local field = self:get_focused_field()
  field.input_field:backspace()
  self:sync_ygg_and_midi(field)
end

function editor:sync_ygg_and_midi(field)
  local fields = self:get_fields()
  if field.field_id == "ygg_note" then
    fields['midi_note'].input_field:clear()
    local midi = music:convert("ygg_to_midi", tostring(field.input_field))
    if midi ~= nil then
      fields['midi_note'].input_field:load_string(midi)
    end
  elseif field.field_id == "midi_note" then
    fields['ygg_note'].input_field:clear()
    local ygg_table = music:convert("midi_to_ygg", tostring(field.input_field))
    if ygg_table ~= nil and ygg_table[1] ~= nil then
      fields['ygg_note'].input_field:load_string(ygg_table[1])
    end
  end
end

function editor:commit()
  if self:is_open() then
    graphics:draw_commit()
  end
  for k, field in pairs(self:get_fields()) do
    local new_value = tostring(field.input_field)
    if tostring(field.value_getter()) ~= new_value then
      if new_value == "" then
        field.value_clear()
      else
        field.value_setter(new_value)
      end
    end
  end
  local cache = self:get_slot()
  self:clear()
  tracker:refresh()
  self:activate(cache:get_x(), cache:get_y())
end



-- getters & setters



function editor:get_title()
  if self:get_slot() == nil or self:get_track() == nil then return "EMPTINESS..." end
  local ipn = self:get_slot():get_ipn_note()
  return "X" .. self:get_track():get_x() .. "Y" .. self:get_slot():get_y() .. (ipn ~= nil and ipn or "")
end


function editor:is_valid()
  for k, field in pairs(self:get_fields()) do
    if not self:validate(field) then
      return false
    end
  end
  return true
end

function editor:validate(field)
  if tostring(field.input_field) == "" then
    return true
  elseif field.validator(tostring(field.input_field)) then
    return true
  else
    return false
  end
end

function editor:is_unsaved_changes()
  for k, field in pairs(self:get_fields()) do
    local old_value = field.value_getter()
    if old_value == nil and not field.input_field:is_empty() then
      return true
    elseif old_value ~= nil and tostring(old_value) ~= tostring(field.input_field) then
      return true
    end
  end
  return false
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

function editor:set_field_index(i)
  self.field_index = i
end

function editor:get_field_index()
  return self.field_index
end

function editor:get_field_by_index(i)
  return self.fields[self.field_index[i]]
end

function editor:get_focused_field()
  return self.fields[self.field_index[self.tab_index]]
end

function editor:set_fields(t)
  self.fields = t
end

function editor:get_fields()
  return self.fields
end

return editor