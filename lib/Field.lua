Field = {}

function Field:new(width)
  local f = setmetatable({}, { 
    __index = Field,
    __tostring = function(f) return f:to_string() end
  })
  f.id = fn.id("field")
  f.width = width
  f.offset = 0
  f.overflow = false
  f.text_buffer = {}
  f.extents_buffer = {}
  f.cursor_index = 0
  f.focus = false
  return f
end

function Field:to_string()
  local out = ""
  for k, v in pairs(self:get_text_buffer()) do
    out = out .. v
  end
  return out
end

function Field:refresh()
  if self:sum_extents(self:get_cursor_index()) > self:get_width() then
    self:set_overflow(true)
    self:set_offset(self:get_width() - self:sum_extents(self:get_cursor_index()))
  else
    self:set_overflow(false)
    self:set_offset(0)
  end
end

function Field:add(s)
  local new_index = self:get_cursor_index() + 1
  table.insert(self.text_buffer, new_index, s)
  local extents = screen.text_extents(s)
  if s == " " then
    -- force spaces to have a width of 3px
    extents = 3
  end
  table.insert(self.extents_buffer, new_index, extents)
  self:move_cursor_index(1)
  self:refresh()
end

function Field:load_string(s)
  local ts = tostring(s)
  for i = 1, #ts do
    self:add(ts:sub(i, i))
  end
end

function Field:backspace()
  if self.cursor_index > 0 then
    table.remove(self.text_buffer, self.cursor_index)
    table.remove(self.extents_buffer, self.cursor_index)
    self:move_cursor_index(-1)
  end
  self:refresh()
end

function Field:clear()
  self.text_buffer = {}
  self.extents_buffer = {}
  self.cursor_index = 0
  self:refresh()
end

function Field:set_focus(bool)
  self.focus = bool
end

function Field:is_focus()
  return self.focus
end

function Field:is_empty()
  return #self.text_buffer == 0
end

function Field:move_cursor_index(i)
  self.cursor_index = util.clamp(self.cursor_index + i, 0, #self:get_extents_buffer())
  self:refresh()
end

function Field:space_move_cursor_index(i)  
  local seek_forward = i > 0
  local cached_cursor_index = self:get_cursor_index()
  local space_table = {}
  local eb_count = #self:get_extents_buffer()
  -- build up a table of all the spaces
  local this = 1
  for k, v in pairs(self:get_text_buffer()) do
    if v == " " then
      space_table[#space_table + 1] = this - 1 -- left of the space
      space_table[#space_table + 1] = this     -- right of the space
    end
    this = this + 1
  end
  -- insert the very start and end of the string
  space_table[0] = 0                       
  space_table[#space_table + 1] = eb_count
  if seek_forward and (cached_cursor_index == eb_count) then   -- the cursor is already at the end
    -- do nothing
  elseif not seek_forward and (cached_cursor_index == 0) then   -- the cursor is already at the beginning
    -- do nothing
  elseif seek_forward then   -- we're going forward, so find the next space index
    local iterator = 1
    repeat
      self.cursor_index = space_table[iterator]
      iterator = iterator + 1
    until (self.cursor_index > cached_cursor_index)
  elseif not seek_forward then   -- we're going backward, so find the last space index
    local iterator = #space_table
    repeat
      self.cursor_index = space_table[iterator]
      iterator = iterator - 1
    until (self.cursor_index < cached_cursor_index)
  end
  self:refresh()
end

function Field:get_cursor_index()
  return self.cursor_index
end

function Field:set(text_table, extents_table)
  self.text_buffer = text_table
  self.extents_buffer = extents_table
  self:refresh()
end

function Field:get_extents_buffer()
  return self.extents_buffer
end

function Field:get_text_buffer()
  return self.text_buffer
end

function Field:get_width()
  return self.width
end

function Field:get_offset()
  return self.offset
end

function Field:set_offset(i)
  self.offset = i
end

function Field:set_overflow(b)
  self.overflow = b
end

function Field:is_overflow()
  return self.overflow
end

function Field:sum_extents(n)
  local sum = 0
  local i = 1
  local eb = self:get_extents_buffer()
  for k, v in pairs(eb) do
    sum = sum + v + 1 -- 1 for the kerning
    if n ~= nil then 
      i = i + 1
      if i > n then
        break
      end
    end
  end
  return sum
end