Branch = {}

-- branches are the space delimited strings
-- leaves are ; : delimited strings, inclusive of the delimiters

function Branch:new(raw_input)
  local b = setmetatable({}, {
    __index = Branch,
  })
  b.raw_input = raw_input ~= nil and raw_input or ""
  b.leaves = {}
  local value = b.raw_input
  if tonumber(b.raw_input) then
    b.leaves[1] = tonumber(b.raw_input)
  else
    b.leaves = b:make_leaves(value)
  end
  return b
end

-- Branch:new():make_leaves("#1;200:3;434234.lem:tech")
function Branch:make_leaves(input)
  local result = {}
  local processed = string.gsub(input, ";", " ; ")
  processed = string.gsub(processed, ":", " : ")
  processed = string.gsub(processed, "#", "# ") -- note no leading space
  processed = string.gsub(processed, ">", "> ") -- note no leading space
  processed = string.gsub(processed, "<", "< ") -- note no leading space
  for s in string.gmatch(processed, "([^%s]+)") do
    value = tonumber(s) and tonumber(s) or s
    result[#result + 1] = value
  end
  return result
end