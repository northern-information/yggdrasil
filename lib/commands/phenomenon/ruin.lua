-- RUIN PHENOMENON
-- 1 5 r
commands:register{
  invocations = { "ruin" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1]) 
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):validate_prefix_invocation()
  end,
  payload = function(branch)
    return {
      class = "RUIN",
      phenomenon = true,
      prefix = "ruin",
      x = branch[1].leaves[1], 
      y = branch[2].leaves[1]
    }
  end,
  action = function(payload)
     tracker:update_slot(payload)
  end
}