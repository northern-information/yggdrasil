-- LEVEL
-- 1 level;58
commands:register{
  invocations = { "level", "l" },
  signature = function(branch, invocations)
    if #branch ~= 2 then return false end
    return fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and fn.is_int(branch[2].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "LEVEL",
      level = branch[2].leaves[3] * .01,
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
}