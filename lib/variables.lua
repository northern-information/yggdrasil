local variables = {}

function variables.init()
  variables.database = {}
end

function variables:expand(input)
  for index, variable_value in pairs(self:get_database()) do
    input = string.gsub(input, "$" .. index, variable_value)
  end
  return input
end

function variables:get_item(index)
  return self.database[index]
end

function variables:add_item(index, s)
  self.database[index] = s
end

function variables:remove_item(index)
  self.database[index] = nil
end

function variables:set_database(t)
  self.database = t
end

function variables:get_database()
  return self.database
end

return variables