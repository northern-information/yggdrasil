Validator = {}

function Validator:new(branch, invocations)
  local v = setmetatable({}, { 
    __index = Validator,
  })
  v.branch = branch
  v.invocations = invocations
  v.is_valid = v:is_invocation_match()
  return v
end

function Validator:ok()
  return self.is_valid
end

function Validator:is_invocation_match()
  local result = false
  for k, invocation in pairs(self.invocations) do
    local is_prefix_invocation = self:validate_prefix_invocation()
    local is_string_invocation = self:validate_string_invocation(invocation)
    local is_simple_invocation = self:validate_simple_invocation(invocation)
    local is_complex_invocation = self:validate_complex_invocation(invocation)
    print("is_prefix_invocation", is_prefix_invocation)
    print("is_string_invocation", is_string_invocation)
    print("is_simple_invocation", is_simple_invocation)
    print("is_complex_invocation", is_simple_invocation)
    if is_prefix_invocation 
       or is_string_invocation 
       or is_simple_invocation
       or is_complex_invocation then
      result = true
    end
  end
  return result
end

-- i.e. "#2"
function Validator:validate_prefix_invocation()
  local result = false
  for k, v in pairs(commands:get_prefixes()) do
    if string.find(self.branch.leaves[1], v) then
      result = true
    end
  end
  return result
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
    -- and fn.is_number(self.branch.leaves[3]) -- commenting out to let strings work
end

-- i.e. "midi;d;4"
function Validator:validate_complex_invocation(invocation)
 return #self.branch.leaves >= 5
    and self.branch.leaves[1] == invocation
    and self.branch.leaves[2] == ";"
    and self.branch.leaves[4] == ";"
end