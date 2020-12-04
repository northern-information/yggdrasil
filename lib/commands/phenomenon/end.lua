-- END
-- 1 5 x
commands:register{
  invocations = { "end", "x" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1]) 
       and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "END",
      phenomenon = true,
      prefix = "x",
      value = nil,
      x = branch[1].leaves[1], 
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
     tracker:update_slot(payload)
  end
}