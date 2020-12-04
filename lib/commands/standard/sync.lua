-- SYNC
-- sync
-- sync;3
commands:register{
  invocations = { "sync" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return (
      Validator:new(branch[1], invocations):ok()
    ) or ( 
      Validator:new(branch[1], invocations):ok()
      and fn.is_int(branch[1].leaves[3])
    )
  end,
  payload = function(branch)
    return {
      class = "SYNC",
      y = branch[1].leaves[3] or nil
    }
  end,
  action = function(payload)
    tracker:sync(payload.y)
  end
}