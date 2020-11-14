Field = {}

function Field:new()
  local f = setmetatable({}, { 
    __index = Field,
    __tostring = function(f) return f:to_string() end
  })
  f.id = fn.id("field")
  f.text_buffer = {}
  f.extents_buffer = {}
  f.cursor_index = 0
  return f
end

function Field:to_string()
  local out = ""
  for k, v in pairs(self:get_text_buffer()) do
    out = out .. v
  end
  return out
end

function Field:add(s)
  local new_index = self:get_cursor_index() + 1
  table.insert(self.text_buffer, new_index, s)
  -- force spaces to have a width of 1px
  local extents = (s == " ") and 1 or screen.text_extents(s)
  table.insert(self.extents_buffer, new_index, extents)
  self:move_cursor_index(1)
end

function Field:backspace()
  if self.cursor_index > 0 then
    table.remove(self.text_buffer, self.cursor_index)  
    table.remove(self.extents_buffer, self.cursor_index)
    self:move_cursor_index(-1)
  end
end

function Field:clear()
  self.text_buffer = {}
  self.extents_buffer = {}
  self.cursor_index = 0
end

function Field:is_empty()
  return #self.text_buffer == 0
end

function Field:move_cursor_index(i)
  self.cursor_index = util.clamp(self.cursor_index + i, 0, #self.extents_buffer)
end

function Field:get_cursor_index()
  return self.cursor_index
end

function Field:set(text_table, extents_table)
  self.text_buffer = text_table
  self.extents_buffer = extents_table
end

function Field:get_extents_buffer()
  return self.extents_buffer
end

function Field:get_text_buffer()
  return self.text_buffer
end