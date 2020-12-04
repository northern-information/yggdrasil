-- REMOVE
-- 1 rm
-- 1 2 rm
commands:register{
  invocations = { "remove", "rm" },
  signature = function(branch, invocations)
    if #branch ~=2 and #branch ~= 3 then return false end
    return (
      #branch == 2
      and fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
    ) or (
      #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
    )
  end,
  payload = function(branch)
    return {
        class = "REMOVE",
        x = branch[1].leaves[1], 
        y = fn.is_int(branch[2].leaves[1]) and branch[2].leaves[1] or nil,
    }
  end,
  action = function(payload)
    tracker:remove(payload.x, payload.y)
  end
}