Interpreter = {}

function Interpreter:new(raw_input)
  local i = setmetatable({}, {
    __index = Interpreter,
    __tostring = function(i) return i.raw_input end
  })
  i.raw_input = raw_input ~= nil and raw_input or ""
  i.sans_assignment = i.raw_input
  i.assignment_integer = 0
  i.assignment_valid = false
  i.class = "NONE"
  i.branches = {}
  i.payload = {}
  i.valid = false
  i.split = ""
  i:check_assignment()
  i:parse()
  i:validate()
  return i
end

function Interpreter:check_assignment()
  local dollar_start_pos, dollar_end_pos = string.find(self.raw_input, "%$")
  local equals_start_pos, equals_end_pos = string.find(self.raw_input, " = ")
  if dollar_start_pos == 1 and dollar_end_pos == 1 and fn.is_int(equals_end_pos) then
    -- store a version of the string without the assignment, i.e. "$1 = "
    self.sans_assignment = string.sub(self.raw_input, equals_end_pos + 1)
    -- then store the assignment number
    local index = string.sub(self.raw_input, 1, equals_start_pos - 1)
    -- just the integer, gsub returns multiple values hence the double ()
    self.assignment_integer = tonumber((string.gsub(index, "%$", "")))
    -- validate. assignments can be any arbitrary string
    self.assignment_valid = fn.is_int(self.assignment_integer) and string.len(self.sans_assignment) > 0
  end
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
  if self:is_assignment_valid() then
    variables:add_item(self:get_assignment_integer(), self:get_sans_assignment())
  else
    self.action(Command:new(self.payload))
  end
end

function Interpreter:is_valid()
  return self.valid
end

function Interpreter:is_assignment_valid()
  return self.assignment_valid
end

function Interpreter:get_assignment_integer()
  return self.assignment_integer
end

function Interpreter:get_sans_assignment()
  return self.sans_assignment
end