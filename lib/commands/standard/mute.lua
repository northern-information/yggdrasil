-- MUTE
-- mute
-- 1 mute
commands:register{
  invocations = { "mute" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return 
      (
        #branch == 1
        and Validator:new(branch[1], invocations):ok()
      ) or (
        #branch == 2
        and fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
      )
  end,
  payload = function(branch)
    return {
        class = "MUTE",
        x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:mute(payload.x)
    else
      tracker:mute_all()
    end
  end
}