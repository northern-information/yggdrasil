terminal = {}

function terminal.init()
  terminal:set_field(Field:new(128))
  terminal.history_index = 0
  terminal.history = {}
end

function terminal:add(s)
  self:get_field():add(s)
end

function terminal:is_empty()
  return self:get_field():is_empty()
end

function terminal:backspace()
  self:get_field():backspace()
end

function terminal:move_cursor_index(i)
  self:get_field():move_cursor_index(i)
end

function terminal:space_move_cursor_index(i)
  self:get_field():space_move_cursor_index(i)
end

function terminal:execute()
  self:save_history()
  self:set_history_index(0)
  local raw_field = tostring(self:get_field())
  local expanded = variables:expand(tostring(self:get_field())) 
  -- only commands without an assignment can get expanded
  if string.find(raw_field, "=") == nil and raw_field ~= expanded then
    graphics:draw_expand()
    self:get_field():clear()
    self:get_field():load_string(expanded)
  else
    runner:run(tostring(self:get_field()))
    self:set_field(Field:new(128))
  end
end

function terminal:get_history()
  if self.history_index > 0 and #self.history > 0 then
    return self.history[self.history_index]
  end
end

function terminal:save_history()
  table.insert(self.history, 1, {
    history_table = self:get_field():get_text_buffer(),
    history_extents = self:get_field():get_extents_buffer()
  })
end

function terminal:up_history()
  local check = self.history_index + 1
  self:set_history_index(check > #self.history and #self.history or check)
  self:history_cleanup()
end

function terminal:down_history()
  local check = self.history_index - 1
  self:set_history_index(check < 1 and 0 or check)
  self:history_cleanup()
end

function terminal:history_cleanup()
  local history = self:get_history()
  local field = self:get_field()
  field:clear()
  if history ~= nil then
    field:set(history.history_table, history.history_extents)
    field:move_cursor_index(#history.history_extents)
  end
end

function terminal:set_history_index(i)
  self.history_index = i
end

function terminal:set_field(field)
  self.field = field
end

function terminal:get_field()
  return self.field
end

function terminal:set_focus(bool)
  self.field:set_focus(bool)
end

function terminal:is_focus()
  return self.field:get_focus()
end


return terminal