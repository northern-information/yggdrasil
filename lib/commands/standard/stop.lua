-- STOP
-- 1 stop
-- stop
commands:register{
  invocations = { "stop" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return (
      Validator:new(branch[1], invocations):ok()
    ) or (
      fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
    )
  end,
  payload = function(branch)
    return {
      class = "STOP",
      x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:get_track(payload.x):stop()
    else
      tracker:stop()
    end
  end
}