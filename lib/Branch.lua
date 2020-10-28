Branch = {}

-- branches are the space delimited strings

function Branch:new(raw_input)
  local b = setmetatable({}, { __index = Branch })
  b.raw_input = raw_input ~= nil and raw_input or ""
  b.leaves = {}
  local value = b.raw_input
  if tonumber(b.raw_input) then
    value = tonumber(b.raw_input)
  end
  -- todo loop for ; # :
  b.leaves[#b.leaves + 1] = value
  return b
end