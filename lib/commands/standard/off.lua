-- OFF
-- 1 1 off
-- 1 1 o
commands:register{
  invocations = { "off", "o" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return faslse end
    return
      fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "OFF",
      phenomenon = true,
      prefix = "o",
      x = branch[1].leaves[1], 
      y = branch[2].leaves[1]
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
    tracker:select_slot(payload.x, payload.y)
  end
}