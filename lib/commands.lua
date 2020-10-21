commands = {}

function commands.init()
  commands.command = c
  commands.class = ""
  commands.parsed = {}
end

function commands:run(c)
  self:set_command(c)
  self:check_class()
  if self.class == "FOCUS" then
    tracker:focus(self.parsed.x, self.parsed.y)
  else
    print("Error. No matching command for:", self.command)
  end
end

function commands:set_command(c)
  self.command = c
end

function commands:check_class()
  local c = fn.string_split(self.command)
  if #c == 2 and fn.is_int(tonumber(c[1])) and fn.is_int(tonumber(c[2])) then
    self.class = "FOCUS"
    self.parsed = { 
      x = tonumber(c[1]), 
      y = tonumber(c[2])
    }
  else
    self.class = "NONE"
  end
end

return commands