buffer = {}

function buffer.init()
  buffer.b = ""
  buffer.tb = {}
end

function buffer:execute()
  commands:run(self.b)
  self:clear()
end

function buffer:add(s)
  self.b = self.b .. s
  self.tb[#self.tb + 1] = s
end

function buffer:clear()
  self.b = ""
  self.tb = {}
end

function buffer:backspace()
  self.b = self.b:sub(1, -2)
  self.tb[#self.tb] = nil
end

return buffer