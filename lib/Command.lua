Command = {}

function Command:new(payload)
  local c = setmetatable({}, {
    __index = Command,
    __tostring = function(c) return c.prefix .. (c.value ~= nil and c.value or "") end,
  })
  for k, v in pairs(payload) do c[k] = v end
  return c
end