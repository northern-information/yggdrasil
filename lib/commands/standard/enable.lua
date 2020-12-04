-- ENABLE
-- enable
-- 1 enable
commands:register{
  invocations = { "enable" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return end
    return 
      (
        Validator:new(branch[1], invocations):ok()
      ) or (
        fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
      )
  end,
  payload = function(branch)
    return {
        class = "ENABLE",
        x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:enable(payload.x)
    else
      tracker:enable_all()
    end
  end
}