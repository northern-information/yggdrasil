-- LACUNA
-- 1 8 @4
commands:register{
  invocations = { "@" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):validate_prefix_invocation()
      and fn.is_int(branch[3].leaves[2])
  end,
  payload = function(branch)
    return {
      class = "LACUNA",
      phenomenon = true,
      prefix = "@",
      value = branch[3].leaves[2],
      x = branch[1].leaves[1], 
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
}