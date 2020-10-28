buffer = {}

function buffer.init()
  buffer.b = ""
  buffer.tb = {}
  buffer.history_index = 0
  buffer.history = {}
end

function buffer:execute()
  self:save_history()
  self:set_history_index(0)
  runner:run(self.b)
  self:clear()
end

function buffer:add(s)
  self.b = self.b .. s
  self.tb[#self.tb + 1] = s
end

function buffer:set(buffer_string, buffer_table)
  self.b = buffer_string
  self.tb = buffer_table
end

function buffer:clear()
  self.b = ""
  self.tb = {}
end

function buffer:backspace()
  self.b = self.b:sub(1, -2)
  self.tb[#self.tb] = nil
end

function buffer:get_history()
  if self.history_index > 0 and #self.history > 0 then
    return self.history[self.history_index]
  end
end

function buffer:save_history()
  table.insert(self.history, 1, {
    history_string = self.b,
    history_table = self.tb
  })
end

function buffer:up_history()
  local check = self.history_index + 1
  self:set_history_index(check > #self.history and #self.history or check)
end

function buffer:down_history()
  local check = self.history_index - 1
  self:set_history_index(check < 1 and 0 or check)
end

function buffer:set_history_index(i)
  self.history_index = i
end

function buffer:is_empty()
  return #buffer.tb == 0
end

return buffer