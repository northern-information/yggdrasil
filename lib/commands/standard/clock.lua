-- CLOCK
-- 1 clock;5
commands:register{
  invocations = { "clock" },
  signature = function(branch, invocations)
    if #branch ~= 2 then return false end
    return fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and fn.is_number(branch[2].leaves[3])
      and (branch[2].leaves[3] > 0)
      and (branch[2].leaves[3] <= 2)
  end,
  payload = function(branch)
    return {
      class = "CLOCK",
      clock = branch[2].leaves[3],
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
}