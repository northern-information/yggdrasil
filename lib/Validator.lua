Validator = {}

function Validator:new(branch, invocations)
  local v = setmetatable({}, { 
    __index = Validator
  })
  v.branch = branch
  v.invocations = invocations
  v.valid = v:is_invocation_match()
  return v
end

function Validator:ok()
  return self.valid
end

function Validator:is_invocation_match()
  if self.branch == nil then return false end
  local result = false
  for k, invocation in pairs(self.invocations) do
    local is_string_invocation = self:validate_string_invocation(invocation)
    local is_simple_invocation = self:validate_simple_invocation(invocation)
    local is_complex_invocation = self:validate_complex_invocation(invocation)
    if config.settings.debug_validator then
      print("is_string_invocation", is_string_invocation)
      print("is_simple_invocation", is_simple_invocation)
      print("is_complex_invocation", is_simple_invocation)
    end
    if is_string_invocation 
    or is_simple_invocation
    or is_complex_invocation
    or is_variable_invocation then
      result = true
    end
  end
  return result
end

-- i.e. "#2"
function Validator:validate_prefix_invocation()
  for k, v in pairs(self.invocations) do
    if string.find(self.branch.leaves[1], v) then
      return true
    end
  end
  return false
end

-- i.e. "play"
function Validator:validate_string_invocation(invocation)
  return #self.branch.leaves == 1
    and type(self.branch.leaves[1]) == "string"
    and self.branch.leaves[1] == invocation
end

-- i.e. "vel;3"
function Validator:validate_simple_invocation(invocation)
 return #self.branch.leaves == 3
    and self.branch.leaves[1] == invocation
    and self.branch.leaves[2] == ";"
    and self.branch.leaves[3] ~= nil
end

-- i.e. "midi;d;4"
function Validator:validate_complex_invocation(invocation)
 return #self.branch.leaves >= 5
    and self.branch.leaves[1] == invocation
    and self.branch.leaves[2] == ";"
    and self.branch.leaves[3] ~= nil
    and self.branch.leaves[4] == ";"
    and self.branch.leaves[5] ~= nil
end