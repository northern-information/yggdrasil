buffer = {}

function buffer.init()
  buffer.tb = {}
  buffer.eb = {}
  buffer.history_index = 0
  buffer.history = {}
  buffer.cursor_index = 0
end

function buffer:execute()
  self:save_history()
  self:set_history_index(0)
  runner:run(self:get_b())
  self:clear()
end

function buffer:get_b()
  local out = ""
  for k, v in pairs(self.tb) do
    out = out .. v
  end
  return out
end

function buffer:move_cursor_index(i)
  self.cursor_index = util.clamp(self.cursor_index + i, 0, #self.eb)
end

function buffer:add(s)
  table.insert(self.tb, self.cursor_index + 1, s)
  if s == " " then
    table.insert(self.eb, self.cursor_index + 1, 1)
  else
    local extents = screen.text_extents(s)
    table.insert(self.eb, self.cursor_index + 1, extents)
  end
  self:move_cursor_index(1)
end

function buffer:set(buffer_table, extents_table)
  self.tb = buffer_table
  self.eb = extents_table
end

function buffer:clear()
  self.tb = {}
  self.eb = {}
  self.cursor_index = 0
end

function buffer:backspace()
  if self.cursor_index > 0 then
    table.remove(self.tb, self.cursor_index)  
    table.remove(self.eb, self.cursor_index)
    self:move_cursor_index(-1)
  end
end

function buffer:get_history()
  if self.history_index > 0 and #self.history > 0 then
    return self.history[self.history_index]
  end
end

function buffer:save_history()
  table.insert(self.history, 1, {
    history_table = self.tb,
    history_extents = self.eb
  })
end

function buffer:up_history()
  local check = self.history_index + 1
  self:set_history_index(check > #self.history and #self.history or check)
  self:history_cleanup()
end

function buffer:down_history()
  local check = self.history_index - 1
  self:set_history_index(check < 1 and 0 or check)
  self:history_cleanup()
end

function buffer:history_cleanup()
  local history = self:get_history()
  if history ~= nil then
    self:clear()
    self:set(history.history_table, history.history_extents)
    self.cursor_index = #history.history_extents
  else
    self:clear()
  end
end

function buffer:set_history_index(i)
  self.history_index = i
end

function buffer:is_empty()
  return #buffer.tb == 0
end

function buffer:get_cursor_index()
  return self.cursor_index
end

function buffer:get_eb()
  return self.eb
end

function buffer:get_tb()
  return self.tb
end

return buffer