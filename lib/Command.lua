Command = {}

function Command:new(raw_input)
  local c = setmetatable({}, {
    __index = Command,
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

function Command:parse()
  if self.raw_input == nil then return end
  self.split = fn.string_split(self.raw_input)
  for k, v in pairs(self.split) do
    self.branches[#self.branches + 1] = Branch:new(v)
  end
end

function Command:validate()
  for k, v in pairs(commands) do
    if v.signature(self.branches) then
      self.class = k
      self.valid = true
      self.payload = v.payload(self.branches)
      self.action = v.action
    end
  end
end

function Command:execute()
  self.action(self.payload)
end

function Command:is_valid()
  return self.valid
end

function Command:get_payload()
  return self.payload
end