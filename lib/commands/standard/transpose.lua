-- TRANSPOSE_SLOT
-- 1 1 t;1
commands:register{
  invocations = { "transpose", "trans", "t" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
      and fn.is_int(branch[3].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "TRANSPOSE_SLOT",
      value = branch[3].leaves[3],
      x = branch[1].leaves[1],
      y = branch[2].leaves[1]
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
}