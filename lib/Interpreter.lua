Interpreter = {}

function Interpreter:new(raw_input)
  local c = setmetatable({}, {
    __index = Interpreter,
    __tostring = function(c) return c.raw_input end
  })
  c.raw_input = raw_input ~= nil and raw_input or ""
  c.class = "NONE"
  c.branches = {}
  c.payload = {}
  c.valid = false
  c.split = ""
  c:parse()
  c:validate()
  return c
end

function Interpreter:parse()
  if self.raw_input == nil then return end
  self.split = fn.string_split(self.raw_input)
  for k, v in pairs(self.split) do
    self.branches[#self.branches + 1] = Branch:new(v)
  end
end

function Interpreter:validate()
  for k, command in pairs(commands:get_all()) do
    if command.signature(self.branches, command.invocations) then
      self.class = k
      self.valid = true
      self.payload = command.payload(self.branches)
      self.action = command.action
    end
  end
end

function Interpreter:execute()
  self.action(Command:new(self.payload))
end

function Interpreter:is_valid()
  return self.valid
end